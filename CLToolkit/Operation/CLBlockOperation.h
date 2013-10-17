//
//  CLBlockOperation.h
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLOperation.h"

@class CLBlockOperation, RACSignal;
typedef void (^CLBlockOperationBlock)(CLBlockOperation *operation);

@interface CLBlockOperation : CLOperation

// Block implementation instead of subclass implmentation of operation lifetime
@property (copy) CLBlockOperationBlock didStartBlock;
@property (copy) CLBlockOperationBlock didPauseBlock;
@property (copy) CLBlockOperationBlock didResumeBlock;
@property (copy) CLBlockOperationBlock didCancelBlock;
@property (copy) CLBlockOperationBlock didFailBlock;
@property (copy) CLBlockOperationBlock didSucceedBlock;
@property (copy) CLBlockOperationBlock didFinishBlock;

+ (instancetype)operationWithTaskSignal:(RACSignal *)taskSignal;
+ (instancetype)operationWithTaskSignalBlock:(RACSignal *(^)(void))taskSignalBlock;

@end
