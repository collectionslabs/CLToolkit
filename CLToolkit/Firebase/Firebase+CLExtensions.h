//
//  Firebase+CLExtensions.h
//  Collections
//
//  Created by Tony Xiao on 3/23/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

NSString *FEventName(FEventType eventType);
NSString *FEscapeName(NSString *name);
NSString *FUnescapeName(NSString *escapedName);

@interface FQuery (CLExtensions)

// Sends FDataSnapshot
- (RACSignal *)onValue;
- (RACSignal *)onEvent:(FEventType)eventType;

// Sends RACTuple (FDataSnapshot *snapshot, NSStriong *prevName, NSNumber *eventType)
- (RACSignal *)onChild;
- (RACSignal *)onEvents:(NSArray *)eventTypes;
- (RACSignal *)onEventWithPreviousSiblingName:(FEventType)eventType;

@end

@interface Firebase (CLExtensions)

@property (nonatomic, readonly) NSString *pathString;

- (instancetype)objectForKeyedSubscript:(NSString *)subscript;
- (void)setObject:(id)object forKeyedSubscript:(NSString *)subscript;

- (RACSignal *)set:(id)value;
- (RACSignal *)setValue:(id)value withPriority:(id)priority;
- (RACSignal *)remove;

- (RACSignal *)updateChildren:(NSDictionary *)children;

- (RACSignal *)runTransaction:(FTransactionResult* (^) (FMutableData* currentData))block;
- (RACSignal *)runTransactionBlock:(FTransactionResult* (^) (FMutableData* currentData))block withLocalEvents:(BOOL)localEvents;

- (RACSignal *)onDisconnectSet:(id)value;
- (RACSignal *)onDisconnectSetValue:(id)value withPriority:(id)priority;
- (RACSignal *)cancelDisconnectHooks;

- (RACSignal *)authWithCredential:(NSString *)credential;

@end
