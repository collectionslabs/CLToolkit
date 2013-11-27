//
//  CLBlockOperation.m
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Operation.h"
#import "CLBlockOperation.h"

@interface CLBlockOperation ()

@property (copy) RACSignal *(^taskSignalBlock)(void);

@end

@implementation CLBlockOperation

- (void)operationDidStart {
    NSParameterAssert(self.taskSignalBlock);
    RACSignal *taskSignal = self.taskSignalBlock();
    NSParameterAssert(taskSignal);
    @weakify(self);
    [[taskSignal subscribeNext:^(id x) {
        @strongify(self);
        self.result = x;
    } completed:^{
        @strongify(self);
        [self finishWithSuccess];
    } error:^(NSError *error) {
        @strongify(self);
        [self finishWithError:error];
    }] autoDispose:self];
}

+ (instancetype)operationWithTaskBlock:(id (^)(NSError *__autoreleasing *))taskBlock {
    NSParameterAssert(taskBlock);
    return [self operationWithTaskSignalBlock:^RACSignal *{
        NSError *error = nil;
        id result = taskBlock(&error);
        return error ? [RACSignal error:error] : [RACSignal return:result];
    }];
}

+ (instancetype)operationWithTaskSignal:(RACSignal *)taskSignal {
    NSParameterAssert(taskSignal);
    return [self operationWithTaskSignalBlock:^RACSignal *{
        return taskSignal;
    }];
}

+ (instancetype)operationWithTaskSignalBlock:(RACSignal *(^)(void))taskSignalBlock {
    NSParameterAssert(taskSignalBlock);
    CLBlockOperation *operation = [[self alloc] init];
    operation.taskSignalBlock = taskSignalBlock;
    return operation;
}

@end

