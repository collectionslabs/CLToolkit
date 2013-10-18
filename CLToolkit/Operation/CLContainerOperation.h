//
//  CLContainerOperation.h
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLOperation.h"

@interface CLContainerOperation : CLOperation

- (void)addChildOperation:(CLOperation *)operation;
- (void)addChildOperations:(NSArray *)operations;
- (void)startChildOperations;

// To be overriden by subclass

- (void)childOperationsDidUpdateProgress;
- (void)childOperationsDidSucceed;
- (void)childOperationsDidFail:(NSError *)error;

@end
