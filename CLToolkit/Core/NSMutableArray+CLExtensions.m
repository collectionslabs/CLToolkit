//
//  NSMutableArray+CLExtensions.m
//  Collections
//
//  Created by Tony Xiao on 1/28/12.
//  Copyright (c) 2012 Insta Inc. All rights reserved.
//

#import "NSMutableArray+CLExtensions.h"

@implementation NSMutableArray (StackAndQueue)

- (id)firstObject {
    if ([self count])
        return [self objectAtIndex:0];
    return nil;
}

// Stack
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

// Queue
- (id)dequeue {
	id headObject = [self firstObject];
	if (headObject)
		[self removeObjectAtIndex:0];
	return headObject;
}

- (void)enqueue:(id)anObject {
	[self addObject:anObject];
}

@end

@implementation NSMutableArray (CLExtensions)

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
