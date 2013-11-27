//
//  NSURLRequest+CLToolkit.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "NSURLRequest+CLToolkit.h"


@implementation NSURLRequest (CLToolkit)

- (NSMutableURLRequest *)requestByOverridingHeaders:(NSDictionary *)headers {
    NSMutableURLRequest * newRequest = [self mutableCopy];
    [newRequest overrideHTTPHeaders:headers];
    return newRequest;
}

- (NSString *)authorizationHeader {
    return self.allHTTPHeaderFields[@"Authorization"];
}

@end

@implementation NSMutableURLRequest (CLToolkit)

- (void)overrideHTTPHeaders:(NSDictionary *)newHeaders {
    [newHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *header, NSString *value, BOOL *stop) {
        [self setValue:value forHTTPHeaderField:header];
    }];
}

- (void)setAuthorizationHeader:(NSString *)auth {
    [self setValue:auth forHTTPHeaderField:@"Authorization"];
}

@end
