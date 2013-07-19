//
//  NSEntityDescription+CLToolkit.h
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

@interface NSEntityDescription (CLToolkit)

- (NSDictionary *)toOneRelationshipsByName;
- (NSDictionary *)toManyRelationshipsByName;
- (NSDictionary *)toManyOrderedRelationshipsByName;
- (NSDictionary *)toManyUnorderedRelationshipsByName;

@end
