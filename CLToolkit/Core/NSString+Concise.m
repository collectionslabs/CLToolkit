//
//  NSString+Concise.m
//  Collections
//
//  Created by Tony Xiao on 6/30/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Concise.h"

@implementation NSString (Concise)

- (BOOL)contains:(NSString *)substr {
    return [self rangeOfString:substr options:0].location != NSNotFound;
}

- (NSString *)replace:(NSString *)str with:(NSString *)newStr {
    return [self stringByReplacingOccurrencesOfString:str withString:newStr];
}

#pragma mark Regular Expression


- (NSString *)captureRegex:(NSString *)pattern groupIndex:(NSUInteger)groupIndex {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if(regex == nil) {
        Log(@"-- %@", error);
        return nil;
    }
    
    NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if (!result)
        return nil;
    
    if (groupIndex > result.numberOfRanges - 1)
        return nil;
    
    NSRange range = [result rangeAtIndex:groupIndex];
    if (range.location == NSNotFound)
        return nil;
    
    return [self substringWithRange:range];
}

- (NSString *)captureRegex:(NSString *)pattern {
    return [self captureRegex:pattern groupIndex:0];
}

- (BOOL)matchRegex:(NSString *)pattern {    
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if(regex == nil) {
        Log(@"-- %@", error);
        return NO;
    }
    
    NSUInteger n = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    return n == 1;
}

#pragma mark Slicing and Trimming

- (NSString *)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trim:(NSString *)chars {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:chars]];
}

- (NSString *)sliceFrom:(NSInteger)start till:(NSInteger)end {
    NSInteger count = self.length;
    start = (start < 0) ? MAX(count+start, 0) : (start >= count) ? count : start;
    end   = (end < 0)   ? MAX(count+end, 0)   : (end   >= count) ? count   : end;
    return start < end ? [self substringWithRange:NSMakeRange(start, end-start)] : @"";
}

- (NSString *)sliceFrom:(NSInteger)start {
    NSInteger count = self.length;
    start = (start < 0) ? MAX(count+start, 0) : (start >= count) ? count : start;
    return [self substringWithRange:NSMakeRange(start, count-start)];
}

- (NSString *)sliceTill:(NSInteger)end {
    NSInteger count = self.length;
    end   = (end < 0)   ? MAX(count+end, 0)   : (end   >= count) ? count   : end;
    return [self substringWithRange:NSMakeRange(0, end)];
}

#pragma mark Derived strings

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
        result[0], result[1], result[2], result[3],
        result[4], result[5], result[6], result[7],
        result[8], result[9], result[10], result[11],
        result[12], result[13], result[14], result[15]
    ];
}

- (NSString *)safeFilename {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

- (NSString*)URLEncodedString {
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(
                                                                                NULL,
                                                                                (__bridge CFStringRef)self,
                                                                                NULL,
                                                                                (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8);
}

- (NSString *)toUnderscore {
    NSString *delimiter = @"_";
    unichar *buffer = calloc([self length], sizeof(unichar));
    [self getCharacters:buffer];
    NSMutableString *underscored = [NSMutableString string];
    NSString *currChar;
    for (int i = 0; i < [self length]; i++) {
        currChar = [NSString stringWithCharacters:buffer+i length:1];
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:buffer[i]]) {
            if (0 != i) {
                [underscored appendFormat:@"%@%@", delimiter, [currChar lowercaseString]];
            } else {
                [underscored appendFormat:@"%@", [currChar lowercaseString]];
            }
        } else {
            [underscored appendString:currChar];
        }
    }
    
    free(buffer);
    return underscored;
}

- (NSString *)toCamel {
    unichar *buffer = calloc([self length], sizeof(unichar));
	[self getCharacters:buffer ];
	NSMutableString *cameled = [NSMutableString string];
	BOOL capitalizeNext = NO;
	NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"_"];
	for (int i = 0; i < [self length]; i++) {
		NSString *currChar = [NSString stringWithCharacters:buffer+i length:1];
		if([delimiters characterIsMember:buffer[i]]) {
			capitalizeNext = YES;
		} else {
			if(capitalizeNext) {
				[cameled appendString:[currChar uppercaseString]];
				capitalizeNext = NO;
			} else {
				[cameled appendString:currChar];
			}
		}
	}
	free(buffer);
	return cameled;
}

#pragma mark Class Methods

+ (NSString *)stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuid;
}

@end
