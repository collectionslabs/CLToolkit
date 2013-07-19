//
//  NSArray+Slice.h
//  Collections
//
//  Created by Tony Xiao on 6/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Slice)

- (id)randomObject;

- (NSArray *)arrayByRemovingNull;

- (NSArray *)sliceFrom:(NSInteger)start till:(NSInteger)end;
- (NSArray *)sliceFrom:(NSInteger)start;
- (NSArray *)sliceTill:(NSInteger)end;
- (id)sliceAt:(NSInteger)at;
- (NSIndexSet *)indexesOfObjectsIgnoringNotFound:(id<NSFastEnumeration>)objects;

@end
