//
//  NSEntityDescription+CLMapping.m
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "NSAttributeDescription+CLExtensions.h"
#import "Firebase+CLExtensions.h"
#import "NSDictionary+Concise.h"
#import "NSString+Concise.h"
#import "NSDate+Formatting.h"
#import "NSEntityDescription+CLExtensions.h"

@implementation NSEntityDescription (CLMapping)

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
