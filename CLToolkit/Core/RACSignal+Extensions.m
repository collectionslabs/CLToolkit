//
//  RACSignal+Extensions.m
//  medigram
//
//  Created by Tony Xiao on 7/9/13.
//  Copyright (c) 2013 Bradford Toney. All rights reserved.
//

#import "RACSignal+Extensions.h"

@implementation RACSignal (Extensions)

+ (RACSignal *)delay:(NSTimeInterval)seconds {
    return [[[RACSignal interval:seconds] take:1] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock {
    return [self subscribeError:errorBlock completed:completedBlock];
}

@end
