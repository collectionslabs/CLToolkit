//
//  CLAsyncOperation.m
//  Collections
//
//  Created by Tony Xiao on 7/1/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//  MIT License
//

#import "CLAsyncOperation.h"

@interface CLAsyncOperation() {
    BOOL _isFinished;
    BOOL _isExecuting;
}

@property (nonatomic, strong) void(^mainBlock)(CLAsyncOperation *operation);

@end

@implementation CLAsyncOperation {
    RACSubject *_completion;
}

- (id)init {
    if (self = [super init]) {
        _completion = [RACReplaySubject subject];
        [self setCompletionBlock:nil];
    }
    return self;
}

- (void)start {
    [self setIsExecuting:YES];
    [self setIsFinished:NO];
    if (self.mainBlock) {
        self.mainBlock(self);
    } else {
        [self main];
    }
}

- (void)main {
}

- (void)finish:(NSError *)error {
    if (![self.error isEqual:error])
        self.error = error;
    [self setIsExecuting:NO];
    [self setIsFinished:YES];
}

- (void)finish {
    [self finish:self.error];
}

#pragma mark Accessors

- (void)setCompletionBlock:(void (^)(void))block {
    @weakify(self);
    [super setCompletionBlock:^{
        @strongify(self);
        if (self.error) {
            [self->_completion sendError:self.error];
        } else {
            [self->_completion sendCompleted];
        }
        if (block)
            block();
    }];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (void)setIsExecuting:(BOOL)isExecuting {
    [self willChangeValueForKey:@keypath(self.isExecuting)];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@keypath(self.isExecuting)];
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)setIsFinished:(BOOL)isFinished {
    [self willChangeValueForKey:@keypath(self.isFinished)];
    _isFinished = isFinished;
    [self didChangeValueForKey:@keypath(self.isFinished)];
}

#pragma mark Class Methods

+ (instancetype)operationWithBlock:(void (^)(CLAsyncOperation *))block {
    CLAsyncOperation *operation = [[self alloc] init];
    operation.mainBlock = block;
    return operation;
}

@end

@implementation NSBlockOperation (CLToolkit)

+ (instancetype)operationWithBlock:(void (^)(NSBlockOperation *))block {
    __weak NSBlockOperation *weak_operation;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSBlockOperation *strong_operation = weak_operation;
        block(strong_operation);
    }];
    weak_operation = operation;
    return operation;
}

@end

@implementation NSOperation (CLToolkit)

- (void)setCompletionBlockWithOperation:(void (^)(NSOperation *operation))block {
    @weakify(self);
    [self setCompletionBlock:^{
        @strongify(self);
        block(self);
    }];
}

@end


@interface CLOperation ()

@property (assign) BOOL isExecuting;
@property (assign) BOOL isFinished;

@property (assign, readwrite) CGFloat progress;
@property (strong, readwrite) id result;
@property (strong, readwrite) NSError *error;


@end

@implementation CLOperation {
    RACSubject *_progressSignal;
    RACSubject *_resultSignal;
}

- (id)init {
    if (self = [super init]) {
        _progressSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        _resultSignal = [RACReplaySubject replaySubjectWithCapacity:1];
    }
    return self;
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
                case CLOperationStateCancelled:
                case CLOperationStatePaused:
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                    return YES;
                default:
                    return NO;
            }
        case CLOperationStatePaused:
            switch (newState) {
                case CLOperationStateExecuting:
                case CLOperationStateCancelled:
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
            [self willChangeValueForKey:@keypath(self, state)];
            _state = state;
            [self didChangeValueForKey:@keypath(self, state)];
            switch (state) {
                case CLOperationStateExecuting:
                    self.isExecuting = YES;
                    break;
                case CLOperationStatePaused:
                    self.isExecuting = NO;
                    break;
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                case CLOperationStateCancelled:
                    self.isExecuting = NO;
                    self.isFinished = YES;
                    break;
                default:
                    break;
            }
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

- (BOOL)isConcurrent {
    return YES;
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
        [_progressSignal sendCompleted];
        [_resultSignal sendNextAndComplete:result];
    }
}

- (void)failWithError:(NSError *)error {
    self.error = error;
    if ([self transitionToState:CLOperationStateFailed]) {
        [self operationDidFail];
        [_progressSignal sendError:error];
        [_resultSignal sendError:error];
    }
}

- (void)finishWithCancellation {
    if ([self transitionToState:CLOperationStateCancelled]) {
        [self operationDidCancel];
        [self setDefaultErrorWithCode:NSUserCancelledError
                          description:$str(@"Operation cancelled %@", self)];
        [_progressSignal sendError:self.error];
        [_resultSignal sendError:self.error];
    }
}

// User Facing API

- (void)start {
    if ([self transitionToState:CLOperationStateExecuting]) {
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
                        [self finishWithCancellation];
                        return;
                    default:
                        NSParameterAssert([(CLOperation *)operation state] == CLOperationStateSucceeded);
                        break;
                }
            }
        }
        [self operationDidStart];
    }
}

- (void)cancel {
    [super cancel];
    // NOTE: isCancelled will be changed immediately by super, but
    // state doesn't get changed to CLOperationStateCancelled until finishCancellation is called
}

- (void)pause {
    if ([self transitionToState:CLOperationStatePaused])
        [self operationDidPause];
}

- (void)resume {
    if ([self transitionToState:CLOperationStatePaused])
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