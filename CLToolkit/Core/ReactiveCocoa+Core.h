//
//  RACSignal+Core.h
//  Collections
//
//  Created by Tony Xiao on 2/8/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

#define DISPOSE_ARRAY_THEN_NIL(arr) do { \
    [arr makeObjectsPerformSelector:@selector(dispose)]; \
    arr = nil; } while (NO);


@interface RACSignal (Core)

- (RACSignal *)flattenMapValue:(RACStream *(^)(id value))valueBlock
                         error:(RACStream *(^)(NSError *error))errorBlock;
- (RACSignal *)mapValue:(id(^)(id value))valueBlock
                  error:(NSError *(^)(NSError *error))errorBlock;

- (RACSignal *)flattenMapError:(RACStream *(^)(NSError *error))block;
- (RACSignal *)mapError:(NSError *(^)(NSError *error))block;

- (RACSignal *)deliverOnMain;
- (RACSignal *)catchLoop;
- (RACSignal *)doCompletedOrError:(void (^)(NSError *errorOrNil))block;

- (RACDisposable *)subscribeNext:(void (^)(id))nextBlock completed:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock;
- (RACDisposable *)subscribeNext:(void (^)(id))nextBlock completedOrError:(void (^)(NSError *errorOrNil))block;
- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock;
- (RACDisposable *)subscribeCompletedOrError:(void (^)(NSError *errorOrNil))block;

- (RACSignal *)retryWithBackoffSchedule:(RACSequence *)backoffSchedule;

+ (RACSignal *)delay:(NSTimeInterval)seconds;

@end

@interface RACSubject (Core)

- (void)sendNextAndComplete:(id)value;
+ (instancetype)subjectWithName:(NSString *)name;
+ (instancetype)subjectWithSelector:(SEL)selector;
+ (instancetype)subjectWithClassSelector:(SEL)selector;

@end

@interface RACSequence (Core)

// Typically used in exponential backoff algorithms
+ (instancetype)exponentialSequenceWithStart:(NSInteger)start multiplier:(NSInteger)multiplier;

@end

@interface RACDisposable (Core)

// dispose self when linkedObject dealloc's, returns receiver for convenience
- (instancetype)autoDispose:(id)linkedObject;

@end

@interface NSObject (CLRACExtensions)

- (RACSignal *)rac_signalForKeyPath:(NSString *)keyPath;
- (RACSignal *)rac_signalWithInitialValueForKeyPath:(NSString *)keyPath;

- (RACSignal *)rac_changeSignalForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;

@end

@interface NSNotificationCenter (CLRACExtensions)

- (RACSignal *)rac_addObserverForName:(NSString *)name;

@end