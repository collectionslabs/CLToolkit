//
//  NSDictionary+Core.h
//  Collections
//
//  Created by Tony Xiao on 7/5/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

@interface NSDictionary (Core)

- (id)dictionaryByMergingFrom:(NSDictionary *)other;
+ (instancetype)dictionaryWithArrayOfPairs:(NSArray *)pairs;
+ (instancetype)dictionaryWithDictionaries:(NSArray *)dictionaries;

@end

@interface NSMutableDictionary (Core)

- (id)popObjectForKey:(id)key;

@end