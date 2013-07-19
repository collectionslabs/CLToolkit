//
//  CLViewController.h
//  Collections
//
//  Created by Tony Xiao on 6/24/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLWindowState.h"

@interface CLViewController : NSViewController

@property (nonatomic, weak) CLWindowState *state;

- (void)awakeOnceFromNib;

- (id)initWithNibName:(NSString *)nibNameOrNil windowState:(CLWindowState *)state;

@end
