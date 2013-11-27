//
//  NSURLRequest+CLToolkit.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "Networking.h"

@interface NSURLRequest (CLToolkit)

- (NSMutableURLRequest *)requestByOverridingHeaders:(NSDictionary *)headers;

- (NSString *)authorizationHeader;

@end

@interface NSMutableURLRequest (CLToolkit)

- (void)overrideHTTPHeaders:(NSDictionary *)headers;
- (void)setAuthorizationHeader:(NSString *)auth;

@end
