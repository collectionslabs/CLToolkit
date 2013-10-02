//
//  UIViewController+CLToolkit.h
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//


#import "UI.h"

#if TARGETING_IOS

@interface UIViewController (CLToolkit)

- (RACSignal *)dismissViewControllerAnimated:(BOOL)flag;
- (RACSignal *)presentViewController:(UIViewController *)viewController animated:(BOOL)flag;

- (void)cl_logDescendants;

@end

#endif