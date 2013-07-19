//
//  FNode.m
//  Collections
//
//  Created by Tony Xiao on 4/16/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACSignalQueue.h"
#import "FNode.h"

@implementation FNode {
    id _currentValue;
    FDataSnapshot *_lastSnapshot;
    RACDisposable *_onValueListener;
    RACDisposable *_outstandingSet;
}

- (void)_updateCurrentValueWithLastSnapshot {
    if (_lastSnapshot && ![_lastSnapshot.value isEqual:_currentValue ?: [NSNull null]]) {
        [self willChangeValueForKey:@keypath(self.currentValue)];
        _currentValue = (_lastSnapshot.value == [NSNull null]) ? nil : _lastSnapshot.value;
        [self didChangeValueForKey:@keypath(self.currentValue)];
    }
}

- (id)currentValue {
    if (!_onValueListener) {
        _onValueListener = [[[self onValue] subscribeNext:^(FDataSnapshot *snap) {
            _lastSnapshot = snap;
            if (!_outstandingSet)
                [self _updateCurrentValueWithLastSnapshot];
        }] asScopedDisposable];
    }
    return _currentValue;
}

- (void)setCurrentValue:(id)currentValue {
    _currentValue = currentValue;
    _outstandingSet = [[[[self set:currentValue] materialize] subscribeCompleted:^{
        _outstandingSet = nil;
        [self _updateCurrentValueWithLastSnapshot];
    }] asScopedDisposable];
}

- (instancetype)childByAppendingPath:(NSString *)pathString {
    NSString *url = [[super childByAppendingPath:pathString] description];
    return [[[self class] alloc] initWithUrl:url];
}

- (instancetype)childByAutoId {
    NSString *url = [[super childByAutoId] description];
    return [[[self class] alloc] initWithUrl:url];
}

- (id)initWithUrl:(NSString *)url {
    FNode *node = [[[self class] nodeRegistry] objectForKey:url];
    if (node)
        return node;
    
    if (self = [super initWithUrl:url]) {
        [[[self class] nodeRegistry] setObject:self forKey:url];
    }
    return self;
}

#pragma mark Class Methods

+ (NSMapTable *)nodeRegistry {
    static dispatch_once_t __registryOnceToken;
    static NSMapTable *__registry = nil;
    
    dispatch_once(&__registryOnceToken, ^{
        __registry = [NSMapTable strongToWeakObjectsMapTable];
    });
    return __registry;
}

@end


#pragma mark - FNodeGroup

@interface FNodeGroup()

@property (nonatomic, strong) RACSignalQueue *queue;

@end

@implementation FNodeGroup

- (id)initWithNode:(FNode *)node {
    if (self = [super init]) {
        _linkedNodes = node ? [NSSet setWithObject:node] : [NSSet set];
        _queue = [[RACSignalQueue alloc] init];
    }
    return self;
}

- (instancetype)groupByJoiningGroup:(FNodeGroup *)otherGroup {
    FNodeGroup *newGroup = [[FNodeGroup alloc] initWithNode:nil];
    newGroup.linkedNodes = [self.linkedNodes setByAddingObjectsFromSet:otherGroup.linkedNodes];
    newGroup.queue = [self.queue queueByMergingQueue:otherGroup.queue];
    return newGroup;
}

- (RACSignal *)performNext:(RACSignal *(^)(void))block {
    return [self.queue enqueue:block];
}

- (NSString *)description {
    return $str(@"<FNodeGroup: %p nodes: %@>", self, self.linkedNodes);
}

@end

#pragma mark - FLinkedNode

@interface FLinkedNode()

@property (nonatomic, strong) FNodeGroup *group;

@end

@implementation FLinkedNode

- (FNodeGroup *)group {
    return _group ?: (_group = [[FNodeGroup alloc] initWithNode:self]);
}

- (void)linkWithNode:(FLinkedNode *)node {
    if ([self.group.linkedNodes containsObject:node])
        return;
    self.group = node.group = [self.group groupByJoiningGroup:node.group];
}

- (RACSignal *)setNext:(id)value {
    return [self setNextValue:value withPriority:nil];
}

- (RACSignal *)setNextValue:(id)value withPriority:(id)priority {
    return [self.group performNext:^RACSignal *{
        return [self setValue:value withPriority:priority];
    }];
}

@end
