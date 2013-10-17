//
//  NSOperation+Reactive.m
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Operation.h"
#import "NSOperation+Reactive.h"

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