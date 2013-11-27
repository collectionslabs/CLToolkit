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

@property (assign, readwrite) BOOL isPaused;
@property (assign, readwrite) BOOL isSuccess;

@property (assign) UIBackgroundTaskIdentifier backgroundTaskID;

@end

@implementation CLOperation {
    RACSubject *_progressSignal;
    NSString *_name;
}

- (id)init {
    if (self = [super init]) {
        _backgroundTaskID = UIBackgroundTaskInvalid;
        _progressSignal = [RACReplaySubject replaySubjectWithCapacity:1];
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

- (BOOL)isFinished {
    return self.operationState == CLOperationStateFinished;
}

- (BOOL)canTransitionToOperationState:(CLOperationState)newState {
    CLOperationState currentState = self.operationState;
    switch (currentState) {
        case CLOperationStateNotStarted:
            switch (newState) {
                case CLOperationStateExecuting:
                case CLOperationStateFinished:
                    return YES;
                default:
                    return NO;
            }
        case CLOperationStateExecuting:
            return newState == CLOperationStateFinished;
        default:
            return NO;
    }
}

- (BOOL)transitionToOperationState:(CLOperationState)operationState withBlock:(void(^)(void))block {
    @synchronized(self) {
        if ([self canTransitionToOperationState:operationState]) {
            NSArray *affectedKeys = nil;
            switch (operationState) {
                case CLOperationStateExecuting:
                case CLOperationStateNotStarted:
                    affectedKeys = @[@keypath(self, isExecuting)];
                    break;
                case CLOperationStateFinished:
                    affectedKeys = @[@keypath(self, isExecuting), @keypath(self, isFinished)];
                    break;
            }
            [self willChangeValueForKey:@keypath(self, operationState)];
            [self willChangeValuesForKeys:affectedKeys];
            _operationState = operationState;
            if (block)
                block();
            [self didChangeValueForKey:@keypath(self, operationState)];
            [self didChangeValuesForKeys:affectedKeys];
            return YES;
        }
        return NO;
    }
}

// For use by sublcass

- (void)updateProgress:(CGFloat)progress {
    progress = MIN(MAX(progress, 0), 1);
    self.progress = progress;
    [_progressSignal sendNext:@(progress)];
}

- (void)finishWithSuccess:(BOOL)success error:(NSError *)error {
    NSParameterAssert(!(success && error));
    [self transitionToOperationState:CLOperationStateFinished withBlock:^{
        self.isSuccess = success;
        self.error = error;
        if (success) {
            [self operationDidSucceed];
            [self updateProgress:1];
            [_progressSignal sendCompleted];
        } else {
            [self operationDidFail];
            [_progressSignal sendError:error];
        }
        [self operationDidFinish];
        [self endBackgroundTask];
    }];
}

- (void)finishWithSuccess {
    [self finishWithSuccess:YES error:nil];
}

- (void)finishWithError:(NSError *)error {
    [self finishWithSuccess:NO error:error];
}

// User Facing API

- (void)start {
    [self transitionToOperationState:CLOperationStateExecuting withBlock:^{
        self.operationQueue = [NSOperationQueue currentQueue];
        // Check dependencies.
        for (NSOperation *operation in self.dependencies) {
            if ([operation isKindOfClass:[CLOperation class]] && ![(CLOperation *)operation isSuccess]) {
                NSError *error = [NSError errorWithDomain:@"CLOperation"
                                                     code:NSUserCancelledError
                                                 userInfo:@{
                    NSLocalizedDescriptionKey: $str(@"Operation %@ dependency did not succeed %@", self, operation)}];
                [self finishWithError:error];
                return;
            }
        }
        [self updateProgress:0];
        [self operationDidStart];
        
        if (self.backgroundTask) {
            @weakify(self);
            [[[self listenForNotification:UIApplicationDidEnterBackgroundNotification]
              takeUntil:[[self.progressSignal ignoreValues] materialize]] subscribeNext:^(NSNotification *note) {
                @strongify(self);
                [self beginBackgroundTask];
                [self applicationDidEnterBackground:note];
            }];
            [[[self listenForNotification:UIApplicationWillEnterForegroundNotification]
              takeUntil:[[self.progressSignal ignoreValues] materialize]] subscribeNext:^(NSNotification *note) {
                @strongify(self);
                [self endBackgroundTask];
                [self applicationWillEnterForeground:note];
            }];
        }
    }];
}

- (void)cancel {
    if (!self.isCancelled) {
        [super cancel];
        [self operationDidCancel];
        [self endBackgroundTask];
    }
}

- (void)pause {
    if (!self.isPaused) {
        self.isPaused = YES;
        [self operationDidPause];
    }
}

- (void)resume {
    if (self.isPaused) {
        self.isPaused = NO;
        [self operationDidResume];
    }
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

