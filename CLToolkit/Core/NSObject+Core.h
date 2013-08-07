//
//  NSObject+Core.h
//  Collections
//
//  Created by Tony Xiao on 3/7/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

@interface NSObject (Core)

- (id)associatedValueForKey:(const char *)key setDefault:(id)defaultValue;

- (void)willChangeValuesForKeys:(id<NSFastEnumeration>)keys;
- (void)didChangeValuesForKeys:(id<NSFastEnumeration>)keys;
- (void)withChangesToKeys:(id<NSFastEnumeration>)keys do:(void (^)(void))block;

- (void)CL_dumpInfo;

+ (void)performSelector:(SEL)sel withDelay:(NSTimeInterval)delay;

// TODO: Add - (instancetype)cl_delay and + (Class)cl_delay
// which return proxy objects that one can call

@end

#if TARGETING_IOS
@interface UIViewController (Core)

- (void)cl_logDescendants;

@end
#endif
