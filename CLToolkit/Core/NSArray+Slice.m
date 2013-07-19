//
//  NSArray+Slice.m
//  Collections
//
//  Created by Tony Xiao on 6/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "NSArray+Slice.h"

@implementation NSArray (Slice)

- (id)randomObject {
    NSUInteger randomIndex = arc4random() % [self count];
    return [self objectAtIndex:randomIndex];
}

- (NSArray *)arrayByRemovingNull {
    return [self filteredArrayUsingPredicate:$pred(@"self != %@", [NSNull null])];
}

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

- (NSIndexSet *)indexesOfObjectsIgnoringNotFound:(id<NSFastEnumeration>)objects {
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    for (id obj in objects) {
        NSInteger index = [self indexOfObject:obj];
        if (index != NSNotFound)
            [indexes addIndex:index];
    }
    return indexes;
}

@end