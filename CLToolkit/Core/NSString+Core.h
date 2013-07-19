//
//  NSString+Core.h
//  Collections
//
//  Created by Tony Xiao on 6/30/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

@interface NSString (Core)

- (BOOL)contains:(NSString *)substr;
- (NSString *)replace:(NSString *)str with:(NSString *)newStr;

- (NSString *)captureRegex:(NSString *)pattern groupIndex:(NSUInteger)groupIndex;
- (NSString *)captureRegex:(NSString *)pattern;
- (BOOL)matchRegex:(NSString *)pattern;

- (NSString *)trim;
- (NSString *)trim:(NSString *)chars;

- (NSString *)sliceFrom:(NSInteger)start till:(NSInteger)end;
- (NSString *)sliceFrom:(NSInteger)start;
- (NSString *)sliceTill:(NSInteger)end;

- (NSString *)md5;
- (NSString *)safeFilename;
- (NSString *)URLEncodedString;

- (NSString *)toCamel;
- (NSString *)toUnderscore;

- (BOOL)validateEmail;

+ (NSString *)stringWithUUID;

@end


