//
//  NSObject+Core.m
//  Collections
//
//  Created by Tony Xiao on 3/7/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Core.h"

@implementation NSObject (Core)

- (id)associatedValueForKey:(const char *)key setDefault:(id)defaultValue {
    id value = [self associatedValueForKey:key];
    if (!value) {
        value = defaultValue;
        [self associateValue:value withKey:key];
    }
    return value;
}

- (void)willChangeValuesForKeys:(id<NSFastEnumeration>)keys {
    for (NSString *key in keys)
        [self willChangeValueForKey:key];
}

- (void)didChangeValuesForKeys:(id<NSFastEnumeration>)keys {
    for (NSString *key in keys)
        [self didChangeValueForKey:key];
}

- (void)withChangesToKeys:(id<NSFastEnumeration>)keys do:(void (^)(void))block {
    [self willChangeValuesForKeys:keys];
    block();
    [self didChangeValuesForKeys:keys];
}

- (void)CL_dumpInfo {
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}


@end
