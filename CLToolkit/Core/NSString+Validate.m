//
//  NSString+Validate.m
//  Collections
//
//  Created by Tony Xiao on 2/27/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)

- (BOOL)validateEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

@end
