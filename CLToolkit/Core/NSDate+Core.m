//
//  NSDate+Core.m
//  Collections
//
//  Created by Tony Xiao on 2/16/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "NSDate+Core.h"

static ISO8601DateFormatter *ISO8601Formatter() {
    static dispatch_once_t __iso8601OnceToken;
    static ISO8601DateFormatter *__iso8601Formatter;
    dispatch_once(&__iso8601OnceToken, ^{
        __iso8601Formatter = [[ISO8601DateFormatter alloc] init];
    });
    return __iso8601Formatter;
}

static NSDateFormatter *RFC2822Formatter() {
    static dispatch_once_t __rfc2822OnceToken;
    static NSDateFormatter *__rfc2822Formatter = nil;
    dispatch_once(&__rfc2822OnceToken, ^{
        __rfc2822Formatter = [[NSDateFormatter alloc] init];
        __rfc2822Formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        __rfc2822Formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZ";
    });
    return __rfc2822Formatter;
}

@implementation NSDate (Core)

- (NSString *)ISO8601 { return [self description]; }
- (NSString *)RFC2822 { return [RFC2822Formatter() stringFromDate:self]; }

+ (NSDate *)dateFromISO8601:(NSString *)dateString {
    AssertMainThread(); // Method not yet thread safe...
    return dateString.length ? [ISO8601Formatter() dateFromString:dateString] : nil;
}

+ (NSDate*)dateFromRFC2822:(NSString *)dateString {
    return dateString.length ? [RFC2822Formatter() dateFromString:dateString] : nil;
}

@end
