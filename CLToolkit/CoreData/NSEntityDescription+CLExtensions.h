//
//  NSEntityDescription+CLMapping.h
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (CLMapping)

- (NSDictionary *)toOneRelationshipsByName;
- (NSDictionary *)toManyRelationshipsByName;
- (NSDictionary *)toManyOrderedRelationshipsByName;
- (NSDictionary *)toManyUnorderedRelationshipsByName;

@end
