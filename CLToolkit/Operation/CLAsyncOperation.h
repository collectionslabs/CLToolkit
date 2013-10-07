//
//  CLAsyncOperation.h
//  Collections
//
//  Created by Tony Xiao on 7/1/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//  MIT License
//

#import <Foundation/Foundation.h>
#import "Operation.h"

// See http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html
// isExecuting | isFinished | isCancelled | State
//      NO           NO            NO       Not yet started
//      YES          NO            NO       Running
//      NO           YES           NO       Finished
//      YES          YES           NO       Impossible (maybe momentary transition)
//      NO           NO            YES      Cancelled, but not started
//      YES          NO            YES      Cancelled, but still running
//      NO           YES           YES      Cancelled, and finished (success unknown, could have finished or aborted)
//      YES          YES           YES      Impossible (maybe momentary transition)

// To use this class, override main but call finish when done
// Also automatically check for isCancelled right before operation begin.
// If cancelled will return immediately without executing main.
@interface CLAsyncOperation : NSOperation

@property (nonatomic, readonly) RACSignal *completion;
@property (nonatomic, strong) NSError *error;

- (void)main; // Subclass should override this to perform work
- (void)finish; // Call finish when done, used by operation itself only
- (void)finish:(NSError *)error;

+ (instancetype)operationWithBlock:(void(^)(CLAsyncOperation *operation))block;

@end

@interface NSBlockOperation (CLToolkit)

+ (id)operationWithBlock:(void (^)(NSBlockOperation *operation))block;

@end

@interface NSOperation (CLToolkit)

- (void)setCompletionBlockWithOperation:(void (^)(NSOperation *operation))block;

@end