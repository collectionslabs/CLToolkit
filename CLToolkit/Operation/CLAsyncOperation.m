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

@implementation CLAsyncOperation

- (void)start {
    [self setIsExecuting:YES];
    [self setIsFinished:NO];
    if (self.mainBlock) {
        self.mainBlock(self);
    } else {
        [self main];
    }
}

- (void)finish {
    [self setIsExecuting:NO];
    [self setIsFinished:YES];
}

#pragma mark Accessors

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (void)setIsExecuting:(BOOL)isExecuting {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)setIsFinished:(BOOL)isFinished {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
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