//
//  NSArray+Core
//  Collections
//
//  Created by Tony Xiao on 6/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

@interface NSArray (Core)
#if TARGETING_OSX
- (id)firstObject;
#endif
- (id)randomObject;

- (NSArray *)arrayByShuffling;
- (NSArray *)arrayByRemovingNulls;
- (NSIndexSet *)indexesOfObjectsIgnoringNotFound:(id<NSFastEnumeration>)objects;

// Slicing

- (NSArray *)sliceFrom:(NSInteger)start till:(NSInteger)end;
- (NSArray *)sliceFrom:(NSInteger)start;
- (NSArray *)sliceTill:(NSInteger)end;
- (id)sliceAt:(NSInteger)at;

@end

@interface NSMutableArray (Core)

- (void)shuffle;

// Stack
- (id)peek;
- (id)pop;
- (void)push:(id)obj;

// Queue
- (id)dequeue;
- (void)enqueue:(id)obj;

// Save set slice
- (void)setObjects:(NSArray *)objects startAtIndex:(NSInteger)start truncateRemaining:(BOOL)truncate;

@end