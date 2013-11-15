//
//  RACSignal+Kiwi.m
//  Collections
//
//  Created by Tony Xiao on 2/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACSignal+Kiwi.h"

@implementation NSObject (KiwiDealloc)

- (KWFutureObject *)kwDeallocFuture {
    return [self.rac_willDeallocSignal kwCompletionFuture];
}

@end

@implementation RACSignal (Kiwi)

- (KWFutureObject *)kwFuture {
    return [self kwFutureWithDefault:nil];
}

- (KWFutureObject *)kwFutureWithDefault:(id)defaultValue {
    __block id lastValue = defaultValue;
    [self subscribeNext:^(id x) {
        lastValue = x;
    }];
    return [KWFutureObject futureObjectWithBlock:^id{
        return lastValue;
    }];
}

- (KWFutureObject *)kwCompletionFuture {
    __block BOOL completed = NO;
    [self subscribeCompleted:^{
        completed = YES;
    }];
    return [KWFutureObject futureObjectWithBlock:^id{
        return @(completed);
    }];
}

- (KWFutureObject *)kwErrorFuture {
    __block NSError *blockError = nil;
    [self subscribeError:^(NSError *error) {
        blockError = error ?: [NSError errorWithDomain:@"Testing" code:0
                                              userInfo:@{NSLocalizedDescriptionKey: @"Placeholder Errror"}];
    }];
    return [KWFutureObject futureObjectWithBlock:^id{
        return blockError;
    }];
}

@end
