//
//  RACSignal+Kiwi.m
//  Collections
//
//  Created by Tony Xiao on 2/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACSignal+Kiwi.h"

@implementation RACSignal (Kiwi)

- (KWFutureObject *)kwFuture {
    return [self kwFutureDefault:nil];
}

- (KWFutureObject *)kwFutureDefault:(id)defaultValue {
    __block id lastValue = defaultValue;
    [self subscribeNext:^(id x) {
        lastValue = x;
    }];
    return [KWFutureObject futureObjectWithBlock:^id{
        return lastValue;
    }];
}

@end
