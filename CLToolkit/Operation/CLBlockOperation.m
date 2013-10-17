//
//  CLBlockOperation.m
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Operation.h"
#import "CLBlockOperation.h"

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
    }];
    return operation;

}

@end

