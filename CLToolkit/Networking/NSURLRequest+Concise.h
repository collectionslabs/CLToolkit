//
//  NSURLRequest+Concise.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Concise)

- (NSMutableURLRequest *)requestByOverridingHeaders:(NSDictionary *)headers;

@end

@interface NSMutableURLRequest (Concise)

- (void)removeHTTPHeaderForKey:(NSString *)key;
- (void)setHTTPHeaders:(NSDictionary *)headers;
- (void)setAuthorization:(NSString *)auth;

@end
