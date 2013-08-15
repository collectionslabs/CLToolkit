//
//  NSView+CLToolkit.m
//  Collections
//
//  Created by Tony Xiao on 2/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "NSView+CLToolkit.h"

#if TARGETING_OSX

@implementation NSView (CLToolkit)

- (void)constrainFillSuperview {
    [self constrainFillSuperviewHorizontally];
    [self constrainFillSuperviewVertically];
}

- (void)constrainFillSuperviewHorizontally {
    if (self.superview)
        [self.superview addConstraints:$constraints(@"H:|[self]|", 0, $vars(self))];
}

- (void)constrainFillSuperviewVertically {
    if (self.superview)
        [self.superview addConstraints:$constraints(@"V:|[self]|", 0, $vars(self))];
}


- (void)constrainSquare {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
}

- (void)logHierarchy {
    NSLog(@"%@", [NSView hierarchicalDescriptionOfView:self level:0]);
}

#pragma mark Debugging

+ (NSString *)hierarchicalDescriptionOfView:(NSView *)view level:(NSUInteger)level {
    
    // Ready the description string for this level
    NSMutableString * builtHierarchicalString = [NSMutableString string];
    
    // Build the tab string for the current level's indentation
    NSMutableString * tabString = [NSMutableString string];
    for (NSUInteger i = 0; i <= level; i++)
        [tabString appendString:@"\t"];
    
    // Get the view's title string if it has one
    NSString * titleString = ([view respondsToSelector:@selector(title)]) ? [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\"%@\" ", [(NSButton *)view title]]] : @"";
    
    // Append our own description at this level
    NSString *ambiguous = view.hasAmbiguousLayout ? @" ### AMBIGUOUS LAYOUT ### ": @" ";
    [builtHierarchicalString appendFormat:@"\n%@<%@: %p>%@%@(%li subviews)", tabString, [view className], view, ambiguous, titleString, [[view subviews] count]];
    
    // Recurse for each subview ...
    for (NSView * subview in [view subviews])
        [builtHierarchicalString appendString:[NSView hierarchicalDescriptionOfView:subview
                                                                              level:(level + 1)]];
    
    return builtHierarchicalString;
}


@end

#endif
