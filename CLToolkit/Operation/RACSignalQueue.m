//
//  RACSignalQueue.m
//  Collections
//
//  Created by Tony Xiao on 4/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACSignalQueue.h"

@implementation RACSignalQueue {
    NSMutableArray *_signalblocks;
    NSMutableArray *_signalSubjects;
    RACSignal *_currentSignal;
}

- (id)init {
    if (self = [super init]) {
        _signalblocks = [NSMutableArray array];
        _signalSubjects = [NSMutableArray array];
    }
    return self;
}

- (void)tryDequeue {
    if (!_currentSignal && _signalblocks.count) {
        _currentSignal = ((RACSignal *(^)(void))[_signalblocks dequeue])();
        NSParameterAssert([_currentSignal isKindOfClass:[RACSignal class]]);
        __block RACDisposable *disposable = [[_currentSignal doCompleted:^{
            _currentSignal = nil;
            [disposable dispose];
            [self tryDequeue];
        }] subscribe:[_signalSubjects dequeue]];
    }
}

- (RACSignal *)enqueue:(RACSignal *(^)(void))block {
    RACSubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [_signalblocks enqueue:[block copy]];
    [_signalSubjects enqueue:subject];
    [self tryDequeue];
    return subject;
}

- (void)cancelAll {
    [_signalSubjects removeAllObjects];
    [_signalblocks removeAllObjects];
}

- (void)cancelAllWithComplete {
    [_signalSubjects makeObjectsPerformSelector:@selector(sendCompleted)];
    [self cancelAll];
}

- (void)cancelAllWithError {
    [_signalSubjects makeObjectsPerformSelector:@selector(sendError:) withObject:$error(@"Cancelled")];
    [self cancelAll];
}

- (RACSignalQueue *)queueByMergingQueue:(RACSignalQueue *)otherQueue {
    RACSignalQueue *newQueue = [[RACSignalQueue alloc] init];
    [newQueue enqueue:^RACSignal *{
        return [RACSignal merge:@[
            [self enqueue:^RACSignal *{ return [RACSignal empty]; }],
            [otherQueue enqueue:^RACSignal *{ return [RACSignal empty]; }]
        ]];
    }];
    return newQueue;
}

@end
