//
//  NSEntityDescription+CLToolkit.m
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "NSAttributeDescription+CLToolkit.h"
#import "NSEntityDescription+CLToolkit.h"

@implementation NSEntityDescription (CLToolkit)

- (NSDictionary *)toOneRelationshipsByName {
    return [self.relationshipsByName select:^BOOL(id key, NSRelationshipDescription *relDesc) {
        return relDesc.isToMany == NO;
    }];
}

- (NSDictionary *)toManyRelationshipsByName {
    return [self.relationshipsByName select:^BOOL(id key, NSRelationshipDescription *relDesc) {
        return relDesc.isToMany == YES;
    }];
}

- (NSDictionary *)toManyOrderedRelationshipsByName {
    return [self.relationshipsByName select:^BOOL(id key, NSRelationshipDescription *relDesc) {
        return relDesc.isToMany == YES && relDesc.isOrdered == YES;
    }];
}

- (NSDictionary *)toManyUnorderedRelationshipsByName {
    return [self.relationshipsByName select:^BOOL(id key, NSRelationshipDescription *relDesc) {
        return relDesc.isToMany == YES && relDesc.isOrdered == NO;
    }];    
}

@end
