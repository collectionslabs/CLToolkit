//
//  NSObject+Core.h
//  Collections
//
//  Created by Tony Xiao on 3/7/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Core)

- (id)associatedValueForKey:(const char *)key default:(id)defaultValue;

- (void)willChangeValuesForKeys:(id<NSFastEnumeration>)keys;
- (void)didChangeValuesForKeys:(id<NSFastEnumeration>)keys;
- (void)withChangesToKeys:(id<NSFastEnumeration>)keys do:(void (^)(void))block;

- (void)CL_dumpInfo;

@end
