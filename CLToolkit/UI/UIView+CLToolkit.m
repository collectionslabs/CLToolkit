//
//  UIView+CLToolkit.m
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "UIView+CLToolkit.h"

#if TARGETING_IOS

@implementation UISearchBar (Core)

- (UITextField *)cl_searchField {
    return [[self.subviews bk_select:^BOOL(UIView *view) {
        return [view isKindOfClass:[UITextField class]];
    }] lastObject];
}

- (UIActivityIndicatorView *)cl_spinner {
    return [[self.cl_searchField.leftView.subviews bk_select:^BOOL(UIView *view) {
        return [view isKindOfClass:[UIActivityIndicatorView class]];
    }] lastObject];
}

- (void)startActivity {
    UIActivityIndicatorView *spinner = [self cl_spinner];
    if (!spinner) {
        UITextField *searchField = [self cl_searchField];
        CGRect bounds = searchField.leftView.bounds;
        NSParameterAssert(searchField);
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(bounds.origin.x + bounds.size.width/2,
                                     bounds.origin.y + bounds.size.height/2);
        spinner.hidesWhenStopped = YES;
        spinner.backgroundColor = [UIColor whiteColor];
        [searchField.leftView addSubview:spinner];
    }
    [spinner startAnimating];
}

- (void)stopActivity {
    [[self cl_spinner] stopAnimating];
}

@end


@implementation UIView (CLToolkit)

- (void)dismissSubviewsWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated {
    // UIAlertView and UIActionSheet will respond to the selector
    for (UIView *view in self.subviews) {
        if ([view respondsToSelector:@selector(dismissWithClickedButtonIndex:animated:)]) {
            [(id)view dismissWithClickedButtonIndex:index animated:animated];
        } else {
            [view dismissSubviewsWithClickedButtonIndex:index animated:animated];
        }
    }
}

- (void)animateWithKeyboard:(NSDictionary *)keyboardInfo block:(void (^)(CGRect keyboardEndFrame))block {
    NSTimeInterval animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardEndFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardEndFrame = [self convertRect:keyboardEndFrame fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    block(keyboardEndFrame);
    [UIView commitAnimations];
}

- (void)cl_logHierarchy:(NSInteger )indent {
    NSString *padding = [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0];
    NSLog(@"%@%@", padding, self.description);
    if (self.subviews.count) {
        NSLog(@"%@  subviews:", padding);
        [self.subviews bk_each:^(UIView *view) {
            [view cl_logHierarchy:indent + 2];
        }];
    }
}

- (void)cl_logHierarchy {
    [self cl_logHierarchy:0];
}

@end

@implementation UIApplication (CLToolkit)

- (void)dismissAllAlerts {
    for (UIWindow *window in self.windows)
        [window dismissSubviewsWithClickedButtonIndex:99 animated:NO];
}

@end

#endif