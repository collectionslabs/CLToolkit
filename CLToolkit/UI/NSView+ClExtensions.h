//
//  NSView+ClExtensions.h
//  Collections
//
//  Created by Tony Xiao on 2/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (ClExtensions)

- (void)constrainFillSuperview;
- (void)constrainFillSuperviewHorizontally;
- (void)constrainFillSuperviewVertically;
- (void)constrainSquare;

- (void)logHierarchy;

+ (NSString *)hierarchicalDescriptionOfView:(NSView *)view level:(NSUInteger)level;

@end
