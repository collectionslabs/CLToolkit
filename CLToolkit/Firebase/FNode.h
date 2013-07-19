//
//  FNode.h
//  Collections
//
//  Created by Tony Xiao on 4/16/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "Firebase+CLExtensions.h"

@interface FNode : Firebase

@property (nonatomic, strong) id currentValue;

- (instancetype)childByAutoId;
- (instancetype)childByAppendingPath:(NSString *)pathString;

@end

@interface FNodeGroup : NSObject

@property (nonatomic, strong) NSSet *linkedNodes;

@end

@interface FLinkedNode : FNode

@property (nonatomic, strong, readonly) FNodeGroup *group;

- (void)linkWithNode:(FNode *)node;

- (RACSignal *)setNext:(id)value;
- (RACSignal *)setNextValue:(id)value withPriority:(id)priority;

@end
