//
//  UIViewController+CLToolkit.m
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "UIViewController+CLToolkit.h"

#if TARGETING_IOS

@implementation UIViewController (CLToolkit)

- (RACSignal *)dismissViewControllerAnimated:(BOOL)flag {
    RACSubject *subject = [RACSubject subjectWithSelector:_cmd];
    [self dismissViewControllerAnimated:flag completion:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)presentViewController:(UIViewController *)viewController animated:(BOOL)flag {
    RACSubject *subject = [RACSubject subjectWithSelector:_cmd];
    [self presentViewController:viewController animated:flag completion:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (void)cl_logDescendants:(NSInteger )indent {
    NSString *padding = [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0];
    NSLog(@"%@%@", padding, self.description);
    if (self.childViewControllers.count) {
        NSLog(@"%@  children:", padding);
        [self.childViewControllers bk_each:^(UIViewController *viewController) {
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