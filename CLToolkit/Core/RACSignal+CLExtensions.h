//
//  RACSignal+CLExtensions.h
//  Collections
//
//  Created by Tony Xiao on 2/8/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (CLExtensions)

- (instancetype)mapWithError:(id(^)(id value))block;

- (RACSignal *)catchLoop;

@end

@interface RACSubject (CLExtensions)

+ (instancetype)subjectWithName:(NSString *)name;
+ (instancetype)subjectWithSelector:(SEL)selector;
+ (instancetype)subjectWithClassSelector:(SEL)selector;

@end

@interface NSObject (CLRACExtensions)

- (RACSignal *)rac_signalForKeyPath:(NSString *)keyPath;
- (RACSignal *)rac_signalWithInitialValueForKeyPath:(NSString *)keyPath;

- (RACSignal *)rac_changeSignalForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;

@end
