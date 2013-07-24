//
//  RACSignalOperation.h
//  Collections
//
//  Created by Tony Xiao on 7/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLAsyncOperation.h"
#import "Operation.h"

// To use this class, override mainSignal. Operation will be finished when signal sends complete or error
// If signal sends an error, operation.error will be set.
@interface RACSignalOperation : CLAsyncOperation

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) RACSignal *signal;

// Designed to be overriden by subclass. Called when operation starts
- (RACSignal *)createSignal;

+ (instancetype)operationWithSignalBlock:(RACSignal *(^)(void))signalBlock;

@end
