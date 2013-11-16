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
                return [operation.progressSignal doCompleted:^{
                    @strongify(self);
                    @strongify(operation);
                    [self childOperationDidSucceed:operation];
                }];
            }]] subscribeNext:^(id x) {
                @strongify(self);
                [self childOperationsDidUpdateProgress];
            } completed:^{
                @strongify(self);
                [self childOperationsDidSucceed];
            } error:^(NSError *error) {
                @strongify(self);
                [self childOperationsDidFail:error];
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
    // TODO: Check can pause here
    [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(pause)];
    [self.childOperationsQueue setSuspended:YES];
    [super pause];
}

- (void)resume {
    // TODO: Check can resume here
    [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(resume)];
    [self.childOperationsQueue setSuspended:NO];
    [super resume];
}

// Override by subclass

- (void)childOperationDidSucceed:(CLOperation *)operation { }
- (void)childOperationsDidUpdateProgress { }
- (void)childOperationsDidSucceed { }
- (void)childOperationsDidFail:(NSError *)error { }

@end
