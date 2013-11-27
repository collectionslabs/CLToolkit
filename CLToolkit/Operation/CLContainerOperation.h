//
//  CLContainerOperation.h
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLOperation.h"

@interface CLContainerOperation : CLOperation


@property (strong, readonly) NSOperationQueue *childOperationsQueue;


- (void)addChildOperation:(CLOperation *)operation;
- (void)addChildOperations:(NSArray *)operations;
- (void)startChildOperations;

// To be overriden by subclass

- (void)childOperationDidStart:(CLOperation *)operation;
- (void)childOperationDidSucceed:(CLOperation *)operation;
- (void)childOperation:(CLOperation *)operation didUpdateProgress:(CGFloat)progress;
- (void)childOperation:(CLOperation *)operation didFailWithError:(NSError *)error;

- (void)allChildOperationsSucceeded;

@end
