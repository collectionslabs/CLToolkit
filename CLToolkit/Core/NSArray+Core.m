//
//  NSArray+Core.m
//  Collections
//
//  Created by Tony Xiao on 6/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "NSArray+Core.h"

@implementation NSArray (Core)

- (id)firstObject {
    return self.count ? self[0] : nil;
}

- (id)randomObject {
    NSUInteger randomIndex = arc4random() % [self count];
    return [self objectAtIndex:randomIndex];
}

- (NSArray *)arrayByShuffling {
    NSMutableArray *mutableArray = [self mutableCopy];
    [mutableArray shuffle];
    return mutableArray;
}

- (NSArray *)arrayByRemovingNulls {
    return [self filteredArrayUsingPredicate:$pred(@"self != %@", [NSNull null])];
}

- (NSIndexSet *)indexesOfObjectsIgnoringNotFound:(id<NSFastEnumeration>)objects {
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    for (id obj in objects) {
        NSInteger index = [self indexOfObject:obj];
        if (index != NSNotFound)
            [indexes addIndex:index];
    }
    return indexes;
}

#pragma mark Slicing

- (NSArray *)sliceFrom:(NSInteger)start till:(NSInteger)end {
    NSInteger count = [self count];
    start = (start < 0) ? MAX(count+start, 0) : (start >= count) ? count : start;
    end   = (end < 0)   ? MAX(count+end, 0)   : (end   >= count) ? count   : end;
    return start < end ? [self subarrayWithRange:NSMakeRange(start, end-start)] : @[];
}

- (NSArray *)sliceFrom:(NSInteger)start {
    NSInteger count = [self count];
    start = (start < 0) ? MAX(count+start, 0) : (start >= count) ? count : start;
    return [self subarrayWithRange:NSMakeRange(start, count-start)];
}

- (NSArray *)sliceTill:(NSInteger)end {
    NSInteger count = [self count];
    end   = (end < 0)   ? MAX(count+end, 0)   : (end   >= count) ? count   : end;
    return [self subarrayWithRange:NSMakeRange(0, end)];
}

- (id)sliceAt:(NSInteger)at {
    NSInteger count = [self count];
    at = (at >= 0) ? at : count+at;
    return (at >= 0 && at < count) ? self[at] : nil;
}

@end

@implementation NSMutableArray (Core)

- (void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

#pragma mark Stack

- (id)peek {
    return self.lastObject;
}

- (id)pop {
    id lastObject = self.lastObject;
	if (lastObject)
		[self removeLastObject];
	return lastObject;
}

- (void)push:(id)obj {
	[self addObject:obj];
}

#pragma mark Queue
- (id)dequeue {
	id headObject = [self firstObject];
	if (headObject)
		[self removeObjectAtIndex:0];
	return headObject;
}

- (void)enqueue:(id)anObject {
	[self addObject:anObject];
}

#pragma mark Save set slice

- (void)setObjects:(NSArray *)objects startAtIndex:(NSInteger)start truncateRemaining:(BOOL)truncate {
    // First turn negative index into positive index
    while (start < 0)
        start += [self count];
    // Pad to min. length required
    while (start > [self count])
        [self addObject:[NSNull null]];
    // Then replace overlapping objects
    NSUInteger nReplaced = MIN([self count]-start, [objects count]);
    [self replaceObjectsInRange:NSMakeRange(start, nReplaced) withObjectsFromArray:objects range:NSMakeRange(0, nReplaced)];
    // Insert remaining, if any
    [self addObjectsFromArray:[objects subarrayWithRange:NSMakeRange(nReplaced, [objects count]-nReplaced)]];
    // Finally truncate if necessary
    if (truncate)
        [self removeObjectsInRange:NSMakeRange(start+[objects count], [self count]-(start+[objects count]))];
}

@end
