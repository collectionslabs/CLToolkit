//
//  CLValueTransformers.m
//  Collections
//
//  Created by Tony Xiao on 7/4/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLValueTransformers.h"

@implementation CLJSONValueTransformer

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        return [value dataUsingEncoding:NSUTF8StringEncoding];
    return $jsonDumpsData(value);
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSData class]])
        return $jsonLoadsData(value);
    else if ([value isKindOfClass:[NSString class]])
        return $jsonLoads(value);
    return nil;
    // BUG in Apple code?: http://stackoverflow.com/questions/9912707/nsjsonserialization-not-creating-mutable-containers
}

+ (Class)transformedValueClass { return [NSData class]; }

+ (BOOL)allowsReverseTransformation { return YES; }

@end

@implementation CLURLValueTransformer

- (id)transformedValue:(id)value { return [value absoluteString]; }
- (id)reverseTransformedValue:(id)value { return [NSURL URLWithString:value]; }

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

@end

@implementation CLDateToRelativeStringValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if (!value)
        return nil;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:value];
    if (interval < 1) { return @"now"; }
    if (interval < 60) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 second ago"]; }
        return [NSString stringWithFormat:@"%d secs ago", rounded];
    }
    interval = interval / 60;
    if (interval < 60) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 minute ago"]; }
        return [NSString stringWithFormat:@"%d mins ago", rounded];
    }
    interval = interval / 60;
    if (interval < 24) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 hour ago"]; }
        return [NSString stringWithFormat:@"%d hours ago", rounded];
    }
    interval = interval / 24;
    if (interval < 7) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 day ago"]; }
        return [NSString stringWithFormat:@"%d days ago", rounded];
    }
    interval = interval / 7;
    if (interval < 4) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 week ago"]; }
        return [NSString stringWithFormat:@"%d weeks ago", rounded];
    }
    interval = interval / 4;
    if (interval < 12) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 month ago"]; }
        return [NSString stringWithFormat:@"%d months ago", rounded];
    }
    interval = interval / 12;
    int rounded = floor(interval);
    if (rounded == 1) { return [NSString stringWithFormat:@"1 year ago"]; }
    return [NSString stringWithFormat:@"%1.f years ago", interval];
}

@end

@implementation CLFileSizeValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if (!$safeNull(value))
        return nil;
    
    long b = [value longValue];
    double kb = b / 1024.0;
    double mb = kb / 1024.0;
    double gb = mb / 1024.0;
    if (gb >= 1)
        return $str(@"%.1f GB", gb);
    if (mb >= 1)
        return $str(@"%.1f MB", mb);
    if (kb >= 1)
        return $str(@"%.1f KB", kb);
    return $str(@"%ld bytes", b);
}

@end

