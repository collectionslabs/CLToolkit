//
//  RACSignal+Kiwi.h
//  Collections
//
//  Created by Tony Xiao on 2/24/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Testing.h"

@interface RACSignal (Kiwi)

- (KWFutureObject *)kwFuture;
- (KWFutureObject *)kwFutureWithDefault:(id)defaultValue;
- (KWFutureObject *)kwCompletionFuture;
- (KWFutureObject *)kwErrorFuture;

@end
