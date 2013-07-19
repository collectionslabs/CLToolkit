//
//  RACSignalQueue.h
//  Collections
//
//  Created by Tony Xiao on 4/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACSignalQueue : NSObject

// Queue up a task to be performed which returns a signal indicating when it finishes.
// Perform the next task once the previous signal sends complete
- (RACSignal *)enqueue:(RACSignal *(^)(void))block;

- (void)cancelAll;
- (void)cancelAllWithComplete;
- (void)cancelAllWithError;

- (RACSignalQueue *)queueByMergingQueue:(RACSignalQueue *)queue;

@end