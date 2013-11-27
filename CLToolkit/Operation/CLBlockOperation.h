//
//  CLBlockOperation.h
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLOperation.h"

@class RACSignal;
@interface CLBlockOperation : CLOperation

@property (nonatomic, strong) id result;

+ (instancetype)operationWithTaskBlock:(id(^)(NSError **error))taskBlock;
+ (instancetype)operationWithTaskSignal:(RACSignal *)taskSignal;
+ (instancetype)operationWithTaskSignalBlock:(RACSignal *(^)(void))taskSignalBlock;

@end
