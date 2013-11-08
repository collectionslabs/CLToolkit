//
//  NSOperation+Reactive.h
//  CLToolkit
//
//  Created by Tony Xiao on 10/17/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@interface NSOperation (Reactive)

@property (nonatomic, readonly) RACSignal *completionSignal;

@end

@interface NSOperationQueue (CLToolkit)

- (id)initWithConcurrency:(NSUInteger)concurrency;

@end