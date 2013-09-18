//
//  UIView+CLToolkit.h
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "UI.h"

#if TARGETING_IOS

@interface UISearchBar (Core)

- (void)startActivity;
- (void)stopActivity;

@end

@interface UIView (CLToolkit)

- (void)animateWithKeyboard:(NSDictionary *)keyboardInfo block:(void (^)(CGRect keyboardEndFrame))block;

- (void)cl_logHierarchy;

@end

@interface UIApplication (CLToolkit)

- (void)dismissAllAlerts;

@end

#endif