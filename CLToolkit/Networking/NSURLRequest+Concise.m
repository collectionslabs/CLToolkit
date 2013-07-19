//
//  NSURLRequest+Concise.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "NSURLRequest+Concise.h"


@implementation NSURLRequest (Concise)

- (NSMutableURLRequest *)requestByOverridingHeaders:(NSDictionary *)headers {
    NSMutableURLRequest * newRequest = [self mutableCopy];
    [newRequest setHTTPHeaders:headers];
    return newRequest;
}

@end

@implementation NSMutableURLRequest (Concise)

- (void)removeHTTPHeaderForKey:(NSString *)key {
    NSMutableDictionary *headers = [[self allHTTPHeaderFields] mutableCopy];
    if ([headers objectForKey:key]) {
        [headers removeObjectForKey:key];
        [self setAllHTTPHeaderFields:headers];
    }
}

- (void)setHTTPHeaders:(NSDictionary *)newHeaders {
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers addEntriesFromDictionary:[self allHTTPHeaderFields]];
    [headers addEntriesFromDictionary:newHeaders];
    [self setAllHTTPHeaderFields:headers];
}

- (void)setAuthorization:(NSString *)auth {
    if (auth)
        [self setHTTPHeaders:@{@"Authorization": auth}];
    else
        [self removeHTTPHeaderForKey:@"Authorization"];
}

@end
