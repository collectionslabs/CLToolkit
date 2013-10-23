//
//  CLOperation.m
//  Collections
//
//  Created by Tony Xiao on 7/1/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//  MIT License
//

#import "Operation.h"
#import "CLOperation.h"

@interface CLOperation ()

@property (weak, readwrite) NSOperationQueue *operationQueue;

@property (assign, readwrite) CGFloat progress;
@property (strong, readwrite) id result;
@property (strong, readwrite) NSError *error;

@end

@implementation CLOperation {
    RACSubject *_progressSignal;
    RACSubject *_resultSignal;
    CLOperationState _previousState;
}

- (id)init {
    if (self = [super init]) {
        _progressSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        _resultSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        [_progressSignal sendNext:@0];
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.state == CLOperationStateExecuting;
}

- (BOOL)isCancelled {
    return self.state == CLOperationStateCancelled;
}

- (BOOL)isPaused {
    return self.state == CLOperationStatePaused;
}

- (BOOL)isFinished {
    switch (self.state) {
        case CLOperationStateFailed:
        case CLOperationStateSucceeded:
            return YES;
        case CLOperationStateCancelled:
            return _previousState != CLOperationStateNotStarted;
        default:
            return NO;
    }
}

- (BOOL)isNewStateValid:(CLOperationState)newState {
    CLOperationState currentState = self.state;
    switch (currentState) {
        case CLOperationStateNotStarted:
            switch (newState) {
                case CLOperationStateExecuting:
                case CLOperationStateCancelled:
                    return YES;
                default:
                    return NO;
            }
        case CLOperationStateExecuting:
            switch (newState) {
                case CLOperationStatePaused:
                case CLOperationStateCancelled:
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                    return YES;
                default:
                    return NO;
            }
        case CLOperationStatePaused:
            // Allow succeeded and failed for operations that doesn't support pause
            switch (newState) {
                case CLOperationStateExecuting:
                case CLOperationStateCancelled:
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                    return YES;
                default:
                    return NO;
            }
        case CLOperationStateSucceeded:
        case CLOperationStateFailed:
        case CLOperationStateCancelled:
            return NO;
    }
}

- (BOOL)transitionToState:(CLOperationState)state {
    @synchronized(self) {
        if ([self isNewStateValid:state]) {
            NSArray *affectedKeys = nil;
            switch (state) {
                case CLOperationStateExecuting:
                case CLOperationStatePaused:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isPaused)];
                    break;
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished), @keypath(self, isPaused)];
                    break;
                case CLOperationStateCancelled:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished), @keypath(self, isCancelled), @keypath(self, isPaused)];
                    break;
                default:
                    break;
            }
            [self willChangeValueForKey:@keypath(self, state)];
            [self willChangeValuesForKeys:affectedKeys];
            _previousState = _state;
            _state = state;
            [self didChangeValueForKey:@keypath(self, state)];
            [self didChangeValuesForKeys:affectedKeys];
            return YES;
        }
        return NO;
    }
}

- (void)setDefaultErrorWithCode:(NSInteger)code description:(NSString *)description {
    @synchronized(self) {
        if (!self.error)
            self.error = [NSError errorWithDomain:@"CLOperation"
                                             code:code
                                         userInfo:@{NSLocalizedDescriptionKey: description}];
    }
}

// For use by sublcass

- (void)updateProgress:(CGFloat)progress {
    self.progress = progress;
    [_progressSignal sendNext:@(progress)];
}

- (void)succeedWithResult:(id)result {
    self.result = result;
    if ([self transitionToState:CLOperationStateSucceeded]) {
        [self operationDidSucceed];
        [self operationDidFinish];
        [_progressSignal sendCompleted];
        [_resultSignal sendNextAndComplete:result];
    }
}

- (void)failWithError:(NSError *)error {
    self.error = error;
    if ([self transitionToState:CLOperationStateFailed]) {
        [self operationDidFail];
        [self operationDidFinish];
        [_progressSignal sendError:error];
        [_resultSignal sendError:error];
    }
}

// User Facing API

- (void)start {
    if ([self transitionToState:CLOperationStateExecuting]) {
        self.operationQueue = [NSOperationQueue currentQueue];
        // Check dependencies.
        for (NSOperation *operation in self.dependencies) {
            if ([operation isKindOfClass:[CLOperation class]]) {
                switch ([(CLOperation *)operation state]) {
                    case CLOperationStateFailed:
                        [self setDefaultErrorWithCode:-1
                                          description:$str(@"Operation %@ dependency failed %@", self, operation)];
                        [self failWithError:self.error];
                        return;
                    case CLOperationStateCancelled:
                        [self setDefaultErrorWithCode:NSUserCancelledError
                                          description:$str(@"Operation %@ dependency cancelled %@", self, operation)];
                        [self cancel];
                        return;
                    default:
                        NSParameterAssert([(CLOperation *)operation state] == CLOperationStateSucceeded);
                        break;
                }
            }
        }
        [self updateProgress:0];
        [self operationDidStart];
    }
}

- (void)cancel {
    if ([self transitionToState:CLOperationStateCancelled]) {
        [super cancel];
        [self setDefaultErrorWithCode:NSUserCancelledError
                          description:$str(@"Operation cancelled %@", self)];
        [self operationDidCancel];
        [self operationDidFinish];
        [_progressSignal sendError:self.error];
        [_resultSignal sendError:self.error];
    }
}

- (void)pause {
    if ([self transitionToState:CLOperationStatePaused])
        [self operationDidPause];
}

- (void)resume {
    if ([self transitionToState:CLOperationStateExecuting])
        [self operationDidResume];
}

// Subclass Stubs

- (void)operationDidStart { }
- (void)operationDidPause { }
- (void)operationDidResume { }
- (void)operationDidCancel { }
- (void)operationDidFail { }
- (void)operationDidSucceed { }
- (void)operationDidFinish { }

@end

