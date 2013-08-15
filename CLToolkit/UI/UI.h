//
//  UI.h
//  Collections
//
//  Created by Tony Xiao on 7/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#ifndef Collections_UI_h
#define Collections_UI_h

#import "Core.h"

#if TARGETING_IOS

#import "UIView+CLToolkit.h"
#import "UIViewController+CLToolkit.h"

#elif TARGETING_OSX

#import "NSView+CLToolkit.h"
#import "CLViewController.h"
#import "NSAlert+SynchronousSheet.h"
#endif

#endif
