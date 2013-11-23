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

NSString * const CLOperationWillExpireNotification = @"CLOperationWillExpire";

@interface CLOperation ()

@property (weak, readwrite) NSOperationQueue *operationQueue;

@property (assign, readwrite) CGFloat progress;
@property (strong, readwrite) id result;
@property (strong, readwrite) NSError *error;
@property (assign) UIBackgroundTaskIdentifier backgroundTaskID;

@end

@implementation CLOperation {
    RACSubject *_willStartSignal;
    RACSubject *_didStartSignal;
    RACSubject *_didCancelSignal;
    RACSubject *_progressSignal;
    RACSubject *_resultSignal;
    CLOperationState _previousState;
    NSString *_name;
}

- (id)init {
    if (self = [super init]) {
        _backgroundTaskID = UIBackgroundTaskInvalid;
        _willStartSignal = [RACReplaySubject replaySubjectWithCapacity:0];
        _didStartSignal = [RACReplaySubject replaySubjectWithCapacity:0];
        _didCancelSignal = [RACReplaySubject replaySubjectWithCapacity:0];
        _progressSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        _resultSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        [_progressSignal sendNext:@0];
    }
    return self;
}

- (void)addDependency:(NSOperation *)operation {
    if (operation)
        [super addDependency:operation];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.operationState == CLOperationStateExecuting;
}

- (BOOL)isCancelled {
    return self.operationState == CLOperationStateCancelled;
}

- (BOOL)isPaused {
    return self.operationState == CLOperationStatePaused;
}

- (BOOL)isSuccess {
    return self.operationState == CLOperationStateSucceeded;
}

- (BOOL)isFinished {
    switch (self.operationState) {
        case CLOperationStateFailed:
        case CLOperationStateSucceeded:
            return YES;
        case CLOperationStateCancelled:
            // TODO: This means a cancelled operation will never be finished
            // until it is started. This isn't a problem when using operation together
            // with queue, but could be a big problem otherwise
            return _previousState != CLOperationStateNotStarted;
        default:
            return NO;
    }
}

- (BOOL)canTransitionToOperationState:(CLOperationState)newState {
    CLOperationState currentState = self.operationState;
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

- (BOOL)transitionToOperationState:(CLOperationState)operationState {
    @synchronized(self) {
        if ([self canTransitionToOperationState:operationState]) {
            NSArray *affectedKeys = nil;
            switch (operationState) {
                case CLOperationStateExecuting:
                case CLOperationStatePaused:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isPaused)];
                    break;
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished), @keypath(self, isPaused), @keypath(self, isSuccess)];
                    break;
                case CLOperationStateCancelled:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished), @keypath(self, isCancelled), @keypath(self, isPaused), @keypath(self, isSuccess)];
                    break;
                default:
                    break;
            }
            [self willChangeValueForKey:@keypath(self, operationState)];
            [self willChangeValuesForKeys:affectedKeys];
            _previousState = _operationState;
            _operationState = operationState;
            [self didChangeValueForKey:@keypath(self, operationState)];
            [self didChangeValuesForKeys:affectedKeys];
            return YES;
        }
        // Workaround for the NSOperationQueue finish without being started by queue bug
        // allows the operation to finish right after getting started if it was cancelled
        if (_previousState == CLOperationStateNotStarted
            && _operationState == CLOperationStateCancelled
            && operationState == CLOperationStateExecuting) {
            [self willChangeValueForKey:@keypath(self, isFinished)];
            _previousState = CLOperationStateExecuting;
            [self didChangeValueForKey:@keypath(self, isFinished)];
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
    progress = MIN(MAX(progress, 0), 1);
    self.progress = progress;
    [_progressSignal sendNext:@(progress)];
}

- (void)succeedWithResult:(id)result {
    self.result = result;
    if ([self transitionToOperationState:CLOperationStateSucceeded]) {
        [self operationDidSucceed];
        [self operationDidFinish];
        [_progressSignal sendNextAndComplete:@1];
        [_resultSignal sendNextAndComplete:result];
        [self endBackgroundTask];
    }
}

- (void)failWithError:(NSError *)error {
    self.error = error;
    if ([self transitionToOperationState:CLOperationStateFailed]) {
        [self operationDidFail];
        [self operationDidFinish];
        [_progressSignal sendError:error];
        [_resultSignal sendError:error];
        [self endBackgroundTask];
    }
}

// User Facing API

- (void)start {
    if ([self transitionToOperationState:CLOperationStateExecuting]) {
        self.operationQueue = [NSOperationQueue currentQueue];
        // Check dependencies.
        for (NSOperation *operation in self.dependencies) {
            if ([operation isKindOfClass:[CLOperation class]]) {
                switch ([(CLOperation *)operation operationState]) {
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
                        NSParameterAssert([(CLOperation *)operation isSuccess]);
                        break;
                }
            }
        }
        [_willStartSignal sendCompleted];
        [self updateProgress:0];
        [self operationDidStart];
        [_didStartSignal sendCompleted];
        
        if (self.backgroundTask) {
            @weakify(self);
            [[[self listenForNotification:UIApplicationDidEnterBackgroundNotification]
              takeUntil:[self.resultSignal materialize]] subscribeNext:^(NSNotification *note) {
                @strongify(self);
                [self beginBackgroundTask];
                [self applicationDidEnterBackground:note];
            }];
            [[[self listenForNotification:UIApplicationWillEnterForegroundNotification]
             takeUntil:[self.resultSignal materialize]] subscribeNext:^(NSNotification *note) {
                @strongify(self);
                [self endBackgroundTask];
                [self applicationWillEnterForeground:note];
            }];
        }
    }
}

- (void)cancel {
    if ([self transitionToOperationState:CLOperationStateCancelled]) {
        [super cancel];
        [self setDefaultErrorWithCode:NSUserCancelledError
                          description:$str(@"Operation cancelled %@", self)];
        [self operationDidCancel];
        [self operationDidFinish];
        [_progressSignal sendError:self.error];
        [_resultSignal sendError:self.error];
        [_didCancelSignal sendCompleted];
        [self endBackgroundTask];
    }
}

- (void)pause {
    if ([self transitionToOperationState:CLOperationStatePaused])
        [self operationDidPause];
}

- (void)resume {
    if ([self transitionToOperationState:CLOperationStateExecuting])
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

// Background task

- (void)beginBackgroundTask {
    @synchronized(self) {
        @weakify(self);
        self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            @strongify(self);
            [self backgroundTaskWillExpire];
            [NC postNotificationName:CLOperationWillExpireNotification object:self];
            [self endBackgroundTask];
        }];
    }
}

- (void)endBackgroundTask {
    @synchronized(self) {
        if (self.backgroundTaskID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
            self.backgroundTaskID = UIBackgroundTaskInvalid;
        }
    }
}

- (void)backgroundTaskWillExpire { }

// Applications Lifecycle

- (void)applicationDidEnterBackground:(NSNotification *)note { }

- (void)applicationWillEnterForeground:(NSNotification *)note { }

// Debugging
- (NSString *)name {
    return _name;
}

- (instancetype)setName:(NSString *)name {
    _name = name;
    return self;
}

- (NSString *)description {
    if (!self.name)
        return $str(@"<%@ [state: %d]: %p>", [self class], self.operationState, self);
    return $str(@"<%@ [%@] [state: %d]: %p>", [self class], self.name, self.operationState, self);
}

@end

