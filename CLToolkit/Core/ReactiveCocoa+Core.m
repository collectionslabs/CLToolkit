//
//  RACSignal+Core.m
//  Collections
//
//  Created by Tony Xiao on 2/8/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>
#import <ReactiveCocoa/RACKVOTrampoline.h>
#import "ReactiveCocoa+Core.h"

@implementation RACSignal (Core)

- (RACSignal *)flattenMapValue:(RACStream *(^)(id))valueBlock error:(RACStream *(^)(NSError *))errorBlock {
    NSParameterAssert(valueBlock && errorBlock);
    return [[self materialize] flattenMap:^RACStream *(RACEvent *event) {
        switch (event.eventType) {
            case RACEventTypeNext:
                return valueBlock(event.value);
            case RACEventTypeError:
                return errorBlock(event.error);
            case RACEventTypeCompleted:
                return [RACSignal empty];
        }
    }];
}

- (RACSignal *)mapValue:(id (^)(id))valueBlock error:(NSError *(^)(NSError *))errorBlock {
    return [self flattenMapValue:^RACStream *(id value) {
        return [RACSignal return:valueBlock(value)];
    } error:^RACStream *(NSError *error) {
        return [RACSignal error:errorBlock(error)];
    }];
}

- (RACSignal *)flattenMapError:(RACStream *(^)(NSError *))block {
    return [self flattenMapValue:^RACStream *(id value) {
        return [RACSignal return:value];
    } error:block];
}

- (RACSignal *)mapError:(NSError *(^)(NSError *))block {
    return [self flattenMapError:^RACStream *(NSError *error) {
        return [RACSignal return:block(error)];
    }];
}

- (RACSignal *)deliverOnMain {
    return [self deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)catchLoop {
	return [[self bind:^{
		__block id lastValue = nil;
		__block BOOL initial = YES;
        
		return ^(id x, BOOL *stop) {
			if (!initial && (lastValue == x || [x isEqual:lastValue])) return [RACSignal empty];
            
			initial = NO;
			lastValue = x;
			return [RACSignal return:x];
		};
	}] setNameWithFormat:@"[%@] -distinctUntilChanged", self.name];
}

- (RACSignal *)doCompletedOrError:(void (^)(NSError *))block {
    NSCParameterAssert(block != NULL);
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        return [self subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            block(error);
            [subscriber sendError:error];
        } completed:^{
            block(nil);
            [subscriber sendCompleted];
        }];
    }] setNameWithFormat:@"[%@] -doCompletedOrError:", self.name];
}

- (RACDisposable *)subscribeNext:(void (^)(id))nextBlock completed:(void (^)(void))completedBlock error:(void (^)(NSError *))errorBlock {
    return [self subscribeNext:nextBlock error:errorBlock completed:completedBlock];
}

- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock {
    return [self subscribeError:errorBlock completed:completedBlock];
}

- (RACDisposable *)subscribeCompletedOrError:(void (^)(NSError *))block {
    return [self subscribeNext:^(id x){} completedOrError:block];
}

- (RACDisposable *)subscribeNext:(void (^)(id))nextBlock completedOrError:(void (^)(NSError *))block {
    return [self subscribeNext:nextBlock completed:^{
        block(nil);
    } error:^(NSError *error) {
        block(error);
    }];
}

- (RACSignal *)retryWithBackoffSchedule:(RACSequence *)backoffSchedule {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block RACSequence *intervals = backoffSchedule;
        RACDisposable *retryDisposable = [[[self catch:^(NSError *error) {
            if (intervals != nil) {
                NSTimeInterval interval = [intervals.head doubleValue];
                intervals = intervals.tail;
                return [[[RACSignal empty] delay:interval] concat:[RACSignal error:error]];
            } else {
                [subscriber sendError:error];
                [retryDisposable dispose];
                return [RACSignal error:error];
            }
        }] retry] subscribe:subscriber];
        return retryDisposable;
    }];
}

+ (RACSignal *)delay:(NSTimeInterval)seconds {
    return [[RACSignal interval:seconds onScheduler:[RACScheduler currentScheduler]] take:1];
}

@end

@implementation RACDisposable (Core)

- (instancetype)autoDispose:(id)linkedObject {
    [[linkedObject rac_deallocDisposable] addDisposable:self];
    return self;
}

@end

@implementation RACSequence (Core)

+ (instancetype)exponentialSequenceWithStart:(NSInteger)start multiplier:(NSInteger)multiplier {
    return [self sequenceWithHeadBlock:^id{
        return @(start);
    } tailBlock:^RACSequence *{
        return [self exponentialSequenceWithStart:start*multiplier multiplier:multiplier];
    }];
}

@end

@implementation RACSubject (Core)

- (void)sendNextAndComplete:(id)value {
    [self sendNext:value];
    [self sendCompleted];
}

+ (instancetype)subjectWithName:(NSString *)name {
    RACSubject *subject = [self subject];
    subject.name = name;
    return subject;
}

+ (instancetype)subjectWithSelector:(SEL)selector {
    return [[self subject] setNameWithFormat:@"-%@", NSStringFromSelector(selector)];
}

+ (instancetype)subjectWithClassSelector:(SEL)selector {
    return [[self subject] setNameWithFormat:@"+%@", NSStringFromSelector(selector)];
}

@end

@implementation NSObject (CLRACExtensions)

- (RACSignal *)rac_signalForKeyPath:(NSString *)keyPath {
    return [[self rac_changeSignalForKeyPath:keyPath options:0] map:^id(id x) {
        return [self valueForKey:keyPath];
    }];
}

- (RACSignal *)rac_signalWithInitialValueForKeyPath:(NSString *)keyPath {
    return [[self rac_changeSignalForKeyPath:keyPath options:NSKeyValueObservingOptionInitial] map:^id(id x) {
        return [self valueForKey:keyPath];
    }];
}

- (RACSignal *)rac_changeSignalForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    return [RACSignal defer:^RACSignal *{
        @unsafeify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            return [[RACKVOTrampoline alloc] initWithTarget:self observer:nil keyPath:keyPath options:options block:^(id target, id observer, NSDictionary *change) {
                [subscriber sendNext:change];
            }];
        }];
    }];
}

@end

@implementation NSNotificationCenter (CLRACExtensions)

- (RACSignal *)rac_addObserverForName:(NSString *)name {
    return [self rac_addObserverForName:name object:nil];
}

@end
