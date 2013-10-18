//
//  CLContainerOperation.m
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Operation.h"
#import "CLContainerOperation.h"


@interface CLContainerOperation ()

@property (strong, readonly) NSOperationQueue *childOperationsQueue;

@end

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
                return operation.progressSignal;
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
    [super cancel];
    if (self.isCancelled) {
        [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(cancel)];
        [self.childOperationsQueue setSuspended:NO];
    }
}

- (void)pause {
    [super pause];
    if (self.isPaused) {
        [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(pause)];
        [self.childOperationsQueue setSuspended:YES];
    }
}

- (void)resume {
    [super resume];
    if (self.isExecuting) {
        [self.childOperationsQueue.operations makeObjectsPerformSelector:@selector(resume)];
        [self.childOperationsQueue setSuspended:NO];
    }
}

// Override by subclass

- (void)childOperationsDidUpdateProgress { }
- (void)childOperationsDidSucceed { }
- (void)childOperationsDidFail:(NSError *)error { }

@end
