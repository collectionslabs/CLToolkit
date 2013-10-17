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

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.state == CLOperationStateExecuting;
}

- (BOOL)isFinished {
    switch (self.state) {
        case CLOperationStateCancelled:
        case CLOperationStateFailed:
        case CLOperationStateSucceeded:
            return YES;
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
                    affectedKeys = @[@keypath(self, isExecuting)];
                    break;
                case CLOperationStatePaused:
                    affectedKeys = @[@keypath(self, isExecuting)];
                    break;
                case CLOperationStateSucceeded:
                case CLOperationStateFailed:
                case CLOperationStateCancelled:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished)];
                    break;
                default:
                    break;
            }
            [self willChangeValueForKey:@keypath(self, state)];
            [self willChangeValuesForKeys:affectedKeys];
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
    NSLog(@"succeeded %@ %@", self, result);
    self.result = result;
    if ([self transitionToState:CLOperationStateSucceeded]) {
        [self operationDidSucceed];
        [self operationDidFinish];
        [_progressSignal sendCompleted];
        [_resultSignal sendNextAndComplete:result];
    }
}

- (void)failWithError:(NSError *)error {
    NSLog(@"failed %@ %@", self, error);
    self.error = error;
    if ([self transitionToState:CLOperationStateFailed]) {
        [self operationDidFail];
        [self operationDidFinish];
        [_progressSignal sendError:error];
        [_resultSignal sendError:error];
    }
}

- (void)finishWithCancellation {
    NSLog(@"cancelled %@", self);
    if ([self transitionToState:CLOperationStateCancelled]) {
        [self operationDidCancel];
        [self operationDidFinish];
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

@implementation CLBlockOperation

- (void)operationDidStart {
    if (self.didStartBlock)
        self.didStartBlock(self);
}

- (void)operationDidPause {
    if (self.didPauseBlock)
        self.didPauseBlock(self);
}

- (void)operationDidResume {
    if (self.didResumeBlock)
        self.didResumeBlock(self);
}

- (void)operationDidCancel {
    if (self.didCancelBlock)
        self.didCancelBlock(self);
}

- (void)operationDidFail {
    if (self.didFailBlock)
        self.didFailBlock(self);
}

- (void)operationDidSucceed {
    if (self.didSucceedBlock)
        self.didSucceedBlock(self);
}

- (void)operationDidFinish {
    if (self.didFinishBlock)
        self.didFinishBlock(self);
}

+ (instancetype)operationWithTaskSignal:(RACSignal *)taskSignal {
    NSParameterAssert(taskSignal);
    return [self operationWithTaskSignalBlock:^RACSignal *{
        return taskSignal;
    }];
}

+ (instancetype)operationWithTaskSignalBlock:(RACSignal *(^)(void))taskSignalBlock {
    NSParameterAssert(taskSignalBlock);
    CLBlockOperation *operation = [[CLBlockOperation alloc] init];
    __block RACDisposable *disposable;
    [operation setDidStartBlock:^(CLBlockOperation *operation) {
        __block id result = nil;
        RACSignal *taskSignal = taskSignalBlock();
        NSParameterAssert(taskSignal);
        disposable = [taskSignal subscribeNext:^(id x) {
            result = x;
        } completed:^{
            [operation succeedWithResult:result];
        } error:^(NSError *error) {
            [operation failWithError:error];
        }];
    }];
    [operation setDidCancelBlock:^(CLBlockOperation *operation) {
        [disposable dispose];
        [operation finishWithCancellation];
    }];
    return operation;

}

@end

@implementation NSOperation (Reactive)

- (RACSignal *)completionSignal {
    // TODO: Is it better to use the completionBlock or observe the isFinished property?
    @weakify(self);
    return [[RACObserve(self, isFinished) takeUntilBlock:^BOOL(NSNumber *isFinished) {
        return isFinished.boolValue;
    }] then:^RACSignal *{
        @strongify(self);
        if (self.isCancelled)
            return [RACSignal error:$error(@"Operation Cancelled")];
        return [RACSignal empty];
    }];
}

@end
