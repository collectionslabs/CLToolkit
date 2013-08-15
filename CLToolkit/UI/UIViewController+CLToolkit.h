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

- (void)cl_logDescendants;

@end

#endif