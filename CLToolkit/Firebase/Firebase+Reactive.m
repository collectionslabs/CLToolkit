//
//  Firebase+Reactive.m
//  Collections
//
//  Created by Tony Xiao on 3/23/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Firebase+Reactive.h"

#if TARGETING_IOS
#define CALLBACK_ARGS NSError *error, Firebase *ref
#elif TARGETING_OSX
#define CALLBACK_ARGS NSError *error
#endif

static NSError *Error(NSString *desc) {
    return [NSError errorWithDomain:@"com.firebase" code:1 userInfo:@{NSLocalizedDescriptionKey: desc ?: @"Unknown Error"}];
}

NSString *FEventName(FEventType eventType) {
    NSString *name = nil;
    switch (eventType) {
        case FEventTypeChildAdded:
            name = @"FEventTypeChildAdded";
            break;
        case FEventTypeChildRemoved:
            name = @"FEventTypeChildRemoved";
            break;
        case FEventTypeChildChanged:
            name = @"FEventTypeChildChanged";
            break;
        case FEventTypeChildMoved:
            name =  @"FEventTypeChildMoved";
            break;
        case FEventTypeValue:
            name = @"FEventTypeValue";
            break;
    }
    return $str(@"%@[%d]", name, eventType);
}

NSString *FEscapeName(NSString *name) {
    return [name replace:@"/" with:@"\\"];
}

NSString *FUnescapeName(NSString *escapedName) {
    return [escapedName replace:@"\\" with:@"/"];
}

@implementation FQuery (CLToolkit)

- (RACSignal *)onValue {
    return [self onEvent:FEventTypeValue];
}

- (RACSignal *)onEvent:(FEventType)eventType {
    return [[self onEventWithPreviousSiblingName:eventType] map:^id(RACTuple *values) {
        return values.first;
    }];
}

- (RACSignal *)onChild {
    return [self onEvents:@[@(FEventTypeChildAdded), @(FEventTypeChildChanged), @(FEventTypeChildMoved), @(FEventTypeChildRemoved)]];
}

- (RACSignal *)onEvents:(NSArray *)eventTypes {
    return [RACSignal merge:[eventTypes bk_map:^id(NSNumber *eventType) {
        return [[self onEventWithPreviousSiblingName:eventType.intValue] map:^id(RACTuple *values) {
            return RACTuplePack(values.first, values.second, eventType);
        }];
    }]];
}

- (RACSignal *)onEventWithPreviousSiblingName:(FEventType)eventType {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FirebaseHandle handle = [self observeEventType:eventType andPreviousSiblingNameWithBlock:^(FDataSnapshot *snapshot, NSString *prevName) {
            [subscriber sendNext:RACTuplePack(snapshot, prevName)];
#ifdef TARGETING_IOS
        } withCancelBlock:^(NSError *error){
            [subscriber sendError:error ?: Error($str(@"Permission Denied onEvent %@ for %@", FEventName(eventType), self))];
#else
        } withCancelBlock:^{
            [subscriber sendError:Error($str(@"Permission Denied onEvent %@ for %@", FEventName(eventType), self))];
#endif
        }];
        return [RACDisposable disposableWithBlock:^{
            [self removeObserverWithHandle:handle];
        }];
    }];
}

@end

@implementation Firebase (CLToolkit)

- (NSString *)pathString { return [self.description substringFromIndex:self.root.description.length - 1]; }

- (instancetype)objectForKeyedSubscript:(NSString *)subscript {
    return [self childByAppendingPath:subscript];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)subscript {
    [[self childByAppendingPath:subscript] set:object];
}

- (RACSignal *)set:(id)value {
    return [self setValue:value withPriority:nil];
}

- (RACSignal *)setValue:(id)value withPriority:(id)priority {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self setValue:value andPriority:priority withCompletionBlock:^(CALLBACK_ARGS) {
        error ? [subject sendError:error] : [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)remove {
    return [self setValue:nil withPriority:nil];
}

- (RACSignal *)updateChildren:(NSDictionary *)children {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self updateChildValues:children withCompletionBlock:^(CALLBACK_ARGS) {
        error ? [subject sendError:error] : [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)runTransaction:(FTransactionResult *(^)(FMutableData *))block {
    return [self runTransactionBlock:block withLocalEvents:YES];
}

- (RACSignal *)runTransactionBlock:(FTransactionResult *(^)(FMutableData *))block withLocalEvents:(BOOL)localEvents {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self runTransactionBlock:block andCompletionBlock:^(NSError *error, BOOL committed, FDataSnapshot *snapshot) {
        if (error)
            [subject sendError:error];
        else
            [subject sendNext:RACTuplePack(@(committed), snapshot)];
    } withLocalEvents:localEvents];
    return subject;
}

- (RACSignal *)onDisconnectSet:(id)value {
    return [self onDisconnectSetValue:value withPriority:nil];
}

- (RACSignal *)onDisconnectSetValue:(id)value withPriority:(id)priority {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self onDisconnectSetValue:value andPriority:priority withCompletionBlock:^(CALLBACK_ARGS) {
        error ? [subject sendError:error] : [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)cancelDisconnectHooks {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self cancelDisconnectOperationsWithCompletionBlock:^(CALLBACK_ARGS) {
        error ? [subject sendError:error] : [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)authWithCredential:(NSString *)credential {
    RACReplaySubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    [self authWithCredential:credential withCompletionBlock:^(NSError *error, id data) {
        error ? [subject sendError:error] : [subject sendNext:data];
    } withCancelBlock:^(NSError *error) {
        [subject sendError:error];
    }];
    return subject;
}

@end
