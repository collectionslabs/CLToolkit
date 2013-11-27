//
//  CLContainerOperation.m
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Operation.h"
#import "CLContainerOperation.h"

@implementation CLContainerOperation {
    BOOL _childOperationsStarted;
}

- (id)init {
    if (self = [super init]) {
        _childOperationsQueue = [[NSOperationQueue alloc] init];
        [_childOperationsQueue setSuspended:YES];
    }
    return self;
}

- (void)dealloc {
    [_childOperationsQueue cancelAllOperations];
    [_childOperationsQueue setSuspended:NO];
}

- (void)addChildOperation:(CLOperation *)operation {
    NSParameterAssert(_childOperationsStarted == NO);
    if (!operation)
        return;
    NSParameterAssert([operation isKindOfClass:[CLOperation class]]);
    [self.childOperationsQueue addOperation:operation];
}

- (void)addChildOperations:(NSArray *)operations {
    for (CLOperation *operation in operations)
        [self addChildOperation:operation];
}

- (void)startChildOperations {
    @synchronized(self) {
        if (!_childOperationsStarted) {
            @weakify(self);
            [[RACSignal merge:[self.childOperationsQueue.operations map:^id(CLOperation *operation) {
                @weakify(operation);
                // Watch State
                [RACObserve(operation, operationState) subscribeNext:^(NSNumber *state) {
                    @strongify(self);
                    @strongify(operation);
                    CLOperationState operationState = state.longValue;
                    switch (operationState) {
                        case CLOperationStateExecuting:
                            [self childOperationDidStart:operation];
                            break;
                        case CLOperationStateFinished:
                            if (operation.isSuccess)
                                [self childOperationDidSucceed:operation];
                            else
                                [self childOperation:operation didFailWithError:operation.error];
                            break;
                        default:
                            break;
                    }
                }];
                // Watch Progress
                return [operation.progressSignal doNext:^(NSNumber *progress) {
                    @strongify(self);
                    @strongify(operation);
                    [self childOperation:operation didUpdateProgress:progress.doubleValue];
                }];
            }]] subscribeCompleted:^{
                // Watch for all completion
                @strongify(self);
                [self allChildOperationsSucceeded];
            }];
            
            [self.childOperationsQueue setSuspended:NO];
            _childOperationsStarted = YES;
        }
    }
}

- (void)cancel {
    // TODO: Check can cancel here
    [self.childOperationsQueue cancelAllOperations];
    [self.childOperationsQueue setSuspended:NO];
    [super cancel];
}

- (void)pause {
    // TODO: Pause is really not that simple
//    [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(pause)];
    [self.childOperationsQueue setSuspended:YES];
    [super pause];
}

- (void)resume {
    // TODO: Resume is really not that simple, we accidentally start unstarted operations here
//    [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(resume)];
    [self.childOperationsQueue setSuspended:NO];
    [super resume];
}

// Override by subclass

- (void)childOperationDidStart:(CLOperation *)operation { }
- (void)childOperationDidSucceed:(CLOperation *)operation { }
- (void)childOperation:(CLOperation *)operation didUpdateProgress:(CGFloat)progress { }
- (void)childOperation:(CLOperation *)operation didFailWithError:(NSError *)error { }

- (void)allChildOperationsSucceeded { }

@end
