//
//  RACSignal+Core.h
//  Collections
//
//  Created by Tony Xiao on 2/8/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

@interface RACSignal (Core)

- (instancetype)mapWithError:(id(^)(id value))block;
- (RACSignal *)deliverOnMain;
- (RACSignal *)catchLoop;
- (RACDisposable *)subscribeNext:(void (^)(id))nextBlock completed:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock;
- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock;

+ (RACSignal *)delay:(NSTimeInterval)seconds;

@end

@interface RACSubject (Core)

- (void)sendNextAndComplete:(id)value;
+ (instancetype)subjectWithName:(NSString *)name;
+ (instancetype)subjectWithSelector:(SEL)selector;
+ (instancetype)subjectWithClassSelector:(SEL)selector;

@end

@interface NSObject (CLRACExtensions)

- (RACSignal *)rac_signalForKeyPath:(NSString *)keyPath;
- (RACSignal *)rac_signalWithInitialValueForKeyPath:(NSString *)keyPath;

- (RACSignal *)rac_changeSignalForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;

@end
