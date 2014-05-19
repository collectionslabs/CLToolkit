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
    CLOperationStateNotStarted, // All operations start off not started
    CLOperationStateExecuting,
    CLOperationStateFinished // Finish does not imply success, check isSuccess flag
};

extern NSString * const CLOperationWillExpireNotification;

@class RACSignal;
@interface CLOperation : NSOperation

@property (weak, readonly) NSOperationQueue *operationQueue;

@property (nonatomic, assign) BOOL backgroundTask; // Default = NO

@property (assign, readonly) CLOperationState operationState;
@property (assign, readonly) BOOL isPaused;

@property (assign, readonly) CGFloat progress;
@property (assign, readonly) BOOL isSuccess;
@property (strong, readonly) NSError *error;

// Progress signal is very versatile
// Sends @0 right before operationDidStart
// Sends @1 followed by complete when operation succeeds
// Sends error when operation fails
@property (readonly) RACSignal *progressSignal;

// Cancel, pause and resume are optioncally supported by subclasses

// To handle cancel, either check the isCancelled flag at a regular interval
// or override operationDidCancel method. Must call finishWithSuccess:error: to
// mark cancellation is complete and thus remove operation from queue

// To handle pause, either override operationDidPause or check isPaused flag
// Called by user of operation

- (void)start;
- (void)cancel;
- (void)pause;
- (void)resume;

// Called by sublcass / implementors of operation only

- (void)updateProgress:(CGFloat)progress;
- (void)finishWithSuccess;
- (void)finishWithError:(NSError *)error;
- (void)finishWithSuccess:(BOOL)success error:(NSError *)error;

// No-op implementations that should be overriden by subclasses

- (void)operationDidStart;
- (void)operationDidPause;
- (void)operationDidResume;
- (void)operationDidCancel;
- (void)operationDidFail;
- (void)operationDidSucceed;
- (void)operationDidFinish; // Finish = sum of fail + succeed

// Background Task & App Life Cycle
// Life cycle notifications will only be sent if backgroundTask = YES

- (void)backgroundTaskWillExpire;
- (void)applicationDidEnterBackground:(NSNotification *)note;
- (void)applicationWillEnterForeground:(NSNotification *)note;

- (NSString *)name;
- (instancetype)setName:(NSString *)name;

@end
