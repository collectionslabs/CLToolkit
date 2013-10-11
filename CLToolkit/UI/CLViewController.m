//
//  CLViewController.m
//  Collections
//
//  Created by Tony Xiao on 6/24/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLViewController.h"

#if TARGETING_OSX

@implementation CLViewController {
    BOOL _awakenFromNib;
}

- (void)_injectResponderChain {
    [RACObserve(self, view.nextResponder) subscribeNext:^(id nextResponder) {
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

@end

#endif
