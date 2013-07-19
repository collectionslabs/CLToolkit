//
//  CLValueTransformers.m
//  Collections
//
//  Created by Tony Xiao on 7/4/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "CLValueTransformers.h"

@implementation CLWebViewProgressTransformer

- (id)transformedValue:(id)value {
    double val = [value doubleValue] * 100;
    return @(val < 84.5 ? val : 0);
}

+ (Class)transformedValueClass { return [NSNumber class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

@end

@implementation CLJSONValueTransformer

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        return [value dataUsingEncoding:NSUTF8StringEncoding];
    return JSON_DUMPS_DATA(value);
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSData class]])
        return JSON_LOADS_DATA(value);
    else if ([value isKindOfClass:[NSString class]])
        return JSON_LOADS(value);
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

@implementation CLArrayCountValueTransformer

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value { return $uinteger([value count]); }

@end

@implementation CLOppositeBoolValueTransformer

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value { return [NSNumber numberWithBool:![value boolValue]]; }

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
    if (!NOT_NSNULL(value))
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

@implementation CLDisplayAttrValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
- (BOOL)allowReverseTransformation { return NO; }
- (id)transformedValue:(NSDictionary *)attrInfo {
    id value = NOT_NSNULL(attrInfo[@"value"]);
    
    if ([attrInfo[@"type"] isEqualToString:@"date"]) {
        value = [[[CLDisplayDateValueTransformer alloc] init] transformedValue:value];
    } else if ([attrInfo[@"type"] isEqualToString:@"location"]) {
        // TODO Get rid of these stupid hacks
        NSString *loc = [[[CLDisplayLocationValueTransformer alloc] init] transformedValue:value];
        if (loc && NOT_NSNULL(value[@"lat"]) && NOT_NSNULL(value[@"long"])) {
            NSString *url = $str(@"https://maps.google.com/?q=%@,%@", value[@"lat"], value[@"long"]);
            value = $str(@"<a href=\"%@\">%@</a>", url, loc);
        } else {
            value = loc;
        }
    } else if ([attrInfo[@"keypath"] isEqualToString:@"size"] && [attrInfo[@"type"] isEqualToString:@"number"]) {
        value = [[[CLFileSizeValueTransformer alloc] init] transformedValue:value];
    } else {
        value = [value description];
    }

    return value;
}

@end

@implementation CLDisplayTextValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value { return NOT_NSNULL(value); }
- (id)reverseTransformedValue:(id)value { return NOT_NSNULL(value); }

@end

@implementation CLDisplayDateValueTransformer

static ISO8601DateFormatter *formatter;
static CLDateToRelativeStringValueTransformer *transformer;

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if (!NOT_NSNULL(value))
        return nil;
    NSDate *date = [value isKindOfClass:[NSDate class]] ? value : [formatter dateFromString:value];
    return [transformer transformedValue:date];
}

+ (void)initialize {
    formatter = [[ISO8601DateFormatter alloc] init];
    transformer = [[CLDateToRelativeStringValueTransformer alloc] init];
}

@end

@implementation CLDisplayLocationValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    if (!NOT_NSNULL(value) || ![value isKindOfClass:[NSDictionary class]])
        return nil;
    if ([value isKindOfClass:[NSString class]])
        return value;
    NSString *loc = NOT_NSNULL(value[@"name"]);
    if (!loc && NOT_NSNULL(value[@"lat"]) && NOT_NSNULL(value[@"long"]))
        loc = @"Unnamed Location";
//        loc = $str(@"Lat: %.3f Long: %.3f", [value[@"lat"] doubleValue], [value[@"long"] doubleValue]);
    return loc;
}

@end

@implementation CLDisplayImageValueTransformer

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return nil;
}

@end

@implementation CLDisplayNumberValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
    return nil;
}

@end

