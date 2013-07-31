//
//  RACSignalOperation.m
//  Collections
//
//  Created by Tony Xiao on 7/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACSignalOperation.h"


@interface RACSignalOperation() {
    RACDisposable *_disposable;
}

@property (nonatomic, strong) RACSignal *(^signalBlock)(void);

@end

@implementation RACSignalOperation

- (RACSignal *)createSignal {
    return [RACSignal empty];
}

- (void)main {
    self.signal = self.signalBlock ? self.signalBlock() : [self createSignal];
    NSAssert(self.signal, @"mainSignal MUST NOT return nil");
    [self.signal subscribeCompleted:^{
        [self finish];
    } error:^(NSError *error) {
        self.error = error;
        [self finish];
    }];
}

+ (instancetype)operationWithSignalBlock:(RACSignal *(^)(void))signalBlock {
    RACSignalOperation *operation = [[self alloc] init];
    operation.signalBlock = signalBlock;
    return operation;
}

@end

@implementation NSOperation (Reactive)

- (RACSignal *)completionSignal {
    @weakify(self);
    return [[RACAbleWithStart(isFinished) takeUntilBlock:^BOOL(NSNumber *isFinished) {
        return isFinished.boolValue;
    }] sequenceNext:^RACSignal *{
        @strongify(self);
        if (self.isCancelled)
            return [RACSignal error:$error(@"Operation Cancelled")];
        return [RACSignal empty];
    }];
}

@end
