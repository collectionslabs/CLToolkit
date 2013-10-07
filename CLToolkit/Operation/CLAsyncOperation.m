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