//
//  NSMutableArray+CLExtensions.h
//  Collections
//
//  Created by Tony Xiao on 1/28/12.
//  Copyright (c) 2012 Insta Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackAndQueue)

- (id)firstObject;

// Stack
- (id)peek;
- (id)pop;
- (void)push:(id)obj;

// Queue
- (id)dequeue;
- (void)enqueue:(id)obj;

@end

@interface NSMutableArray (CLExtensions)

- (void)setObjects:(NSArray *)objects startAtIndex:(NSInteger)start truncateRemaining:(BOOL)truncate;

@end