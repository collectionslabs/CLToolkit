//
//  NSDictionary+Concise.h
//  Collections
//
//  Created by Tony Xiao on 7/5/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Concise)

- (id)dictionaryByMergingFrom:(NSDictionary *)other;
+ (instancetype)dictionaryWithArrayOfPairs:(NSArray *)pairs;
+ (instancetype)dictionaryWithDictionaries:(NSArray *)dictionaries;

@end

@interface NSMutableDictionary (Concise)

- (id)popObjectForKey:(id)key;

@end