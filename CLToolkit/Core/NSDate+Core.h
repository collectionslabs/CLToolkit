//
//  NSDate+Core.h
//  Collections
//
//  Created by Tony Xiao on 2/16/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Core)

- (NSString *)ISO8601;
- (NSString *)RFC2822;

+ (NSDate *)dateFromISO8601:(NSString *)dateString;
+ (NSDate *)dateFromRFC2822:(NSString *)dateString;

@end
