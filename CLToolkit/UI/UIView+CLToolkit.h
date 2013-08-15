//
//  UIView+CLToolkit.h
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#if TARGETING_IOS

#import "UI.h"

@interface UISearchBar (Core)

- (void)startActivity;
- (void)stopActivity;

@end

@interface UIView (CLToolkit)

- (void)animateWithKeyboard:(NSDictionary *)keyboardInfo block:(void (^)(CGRect keyboardEndFrame))block;

- (void)cl_logHierarchy;

@end

#endif