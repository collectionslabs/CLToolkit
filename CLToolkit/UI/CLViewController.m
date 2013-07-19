//
//  CLViewController.m
//  Collections
//
//  Created by Tony Xiao on 6/24/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLViewController.h"

@implementation CLViewController {
    BOOL _awakenFromNib;
}

- (void)_injectResponderChain {
    [RACAble(view.nextResponder) subscribeNext:^(id nextResponder) {
        if (nextResponder != self) {
            self.nextResponder = nextResponder;
            self.view.nextResponder = self;
        }
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (_awakenFromNib)
        return;
    _awakenFromNib = YES;
    [self awakeOnceFromNib];
}

- (void)awakeOnceFromNib {
    [self _injectResponderChain];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _injectResponderChain];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil windowState:(CLWindowState *)state {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.state = state;
        [self _injectResponderChain];
    }
    return self;
}

@end
