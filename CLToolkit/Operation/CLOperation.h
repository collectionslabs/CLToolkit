//
//  CLOperation.h
//  Collections
//
//  Created by Tony Xiao on 7/1/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//  MIT License
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLOperationState) {
    CLOperationStateNotStarted = 0,
    CLOperationStateExecuting,
    CLOperationStatePaused,
    CLOperationStateCancelled,
    CLOperationStateSucceeded,
    CLOperationStateFailed,
};

@class RACSignal;
@interface CLOperation : NSOperation

@property (readonly) NSOperationQueue *operationQueue;

@property (nonatomic, assign) BOOL backgroundTask; // Default = NO

@property (assign, readonly) CLOperationState operationState;
@property (assign, readonly) CGFloat progress;
@property (strong, readonly) id result;
@property (strong, readonly) NSError *error;

@property (readonly) BOOL isPaused;
@property (readonly) BOOL isSuccess;

// Sends complete event right before operationDidStart gets called
@property (readonly) RACSignal *willStartSignal;
// Sends complete event right after operationDidStart gets called
@property (readonly) RACSignal *didStartSignal;
// Sends NSNumber (progress) for next, complete when finish and error when fail
@property (readonly) RACSignal *progressSignal;
// Sends id (result) for next, complete when finish and error when fail
@property (readonly) RACSignal *resultSignal;

/* Cancelling and pausing
 * Calling cancel and pause will change the state of the operation immediately
 * It is up to the implementor of the operation to check isCancelled / implement
 * operationDidCancel and wind itself down as soon as possible. This 
 * may or may not be a desired behavior. We'll see.
 */

// Called by user of operation

- (void)start;
- (void)cancel;
- (void)pause;
- (void)resume;

// Called by sublcass / implementors of operation only

- (void)updateProgress:(CGFloat)progress;

- (void)succeedWithResult:(id)result;
- (void)failWithError:(NSError *)error;

// No-op implementations that should be overriden by subclasses

- (void)operationDidStart;
- (void)operationDidPause;
- (void)operationDidResume;
- (void)operationDidCancel;
- (void)operationDidFail;
- (void)operationDidSucceed;
- (void)operationDidFinish; // Finish = sum of cancel, fail, succeed


// Background Task & App Life Cycle
// Life cycle notifications will only be sent if backgroundTask = YES

- (void)backgroundTaskWillExpire;
- (void)applicationDidEnterBackground:(NSNotification *)note;
- (void)applicationWillEnterForeground:(NSNotification *)note;

@end
