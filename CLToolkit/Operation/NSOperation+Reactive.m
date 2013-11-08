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
        if (self.isCancelled) {
            NSError *error = nil;
            if ([self respondsToSelector:@selector(error)])
                error = [self performSelector:@selector(error)];
            if (!error) {
                error = [NSError errorWithDomain:@"NSOperation"
                                            code:NSUserCancelledError
                                        userInfo:@{
                    NSLocalizedDescriptionKey: @"Operation cancelled"
                }];
            }
            return [RACSignal error:error];
        }
        return [RACSignal empty];
    }];
}

@end

@implementation NSOperationQueue (CLToolkit)

- (id)initWithConcurrency:(NSUInteger)concurrency {
    if (self = [self init])
        self.maxConcurrentOperationCount = concurrency;
    return self;
}

@end