//
//  UIViewController+CLToolkit.m
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#if TARGETING_IOS

#import "UIViewController+CLToolkit.h"

@implementation UIViewController (CLToolkit)

- (void)cl_logDescendants:(NSInteger )indent {
    NSString *padding = [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0];
    NSLog(@"%@%@", padding, self.description);
    if (self.childViewControllers.count) {
        NSLog(@"%@  children:", padding);
        [self.childViewControllers each:^(UIViewController *viewController) {
            [viewController cl_logDescendants:indent + 2];
        }];
    }
    if (self.presentedViewController) {
        NSLog(@"%@  presented:", padding);
        [self.presentedViewController cl_logDescendants:indent + 2];
    }
}

- (void)cl_logDescendants {
    [self cl_logDescendants:0];
}

@end

#endif