//
//  NSAttributeDescription+CLExtensions.m
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Base64/MF_Base64Additions.h>
#import "NSAttributeDescription+CLExtensions.h"

@implementation NSAttributeDescription (CLExtensions)

- (NSValueTransformer *)valueTransformer {
    NSAssert(self.attributeType == NSTransformableAttributeType, @"Value transformer only valid for transformable attr");
    NSValueTransformer *transformer = [[NSClassFromString(self.valueTransformerName) alloc] init];
    NSAssert(transformer, @"Value transformer specified in model must exist");
    return transformer;
}

- (id)transformedValue:(id)value {
    switch (self.attributeType) {
        case NSDateAttributeType:
            return [value ISO8601];
        case NSTransformableAttributeType:
            return $jsonLoadsData([self.valueTransformer transformedValue:value]);
        case NSBinaryDataAttributeType:
            return [value base64String];
        default:
            return value;
    }
}

- (id)reverseTransformedValue:(id)value {
    switch (self.attributeType) {
        case NSDateAttributeType:
            return [NSDate dateFromISO8601:value];
        case NSTransformableAttributeType:
            return [self.valueTransformer reverseTransformedValue:$jsonDumpsData(value)];
        case NSBinaryDataAttributeType:
            return [NSData dataWithBase64String:value];
        default:
            return value;
    }
}

@end

@implementation NSRelationshipDescription (CLExtensions)

- (BOOL)isInverse { return [self.userInfo[@"isInverse"] boolValue]; }
- (void)setIsInverse:(BOOL)isInverse { [self.userInfo setValue:@(isInverse) forKey:@"isInverse"]; }

@end
