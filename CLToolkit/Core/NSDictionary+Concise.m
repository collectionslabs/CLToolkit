//
//  NSDictionary+Concise.m
//  Collections
//
//  Created by Tony Xiao on 7/5/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "NSDictionary+Concise.h"

@implementation NSDictionary (Concise)

- (id)dictionaryByMergingFrom:(NSDictionary *)other {
    NSMutableDictionary *newDict = [self mutableCopy];
    [newDict addEntriesFromDictionary:other];
    return newDict;
}

+ (instancetype)dictionaryWithArrayOfPairs:(NSArray *)pairs {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSArray *pair in pairs)
        dictionary[pair[0]] = pair[1];
    return dictionary;
}

+ (instancetype)dictionaryWithDictionaries:(NSArray *)dictionaries {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in dictionaries)
        [mutableDict addEntriesFromDictionary:dict];
    return mutableDict;
}

@end


@implementation NSMutableDictionary (Concise)

- (id)popObjectForKey:(id)key {
    id val = [self objectForKey:key];
    if (val)
        [self removeObjectForKey:key];
    return val;
}

@end