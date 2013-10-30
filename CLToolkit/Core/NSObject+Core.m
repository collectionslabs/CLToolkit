//
//  NSObject+Core.m
//  Collections
//
//  Created by Tony Xiao on 3/7/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
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

- (void)changeValuesForKeys:(id<NSFastEnumeration>)keys {
    [self willChangeValuesForKeys:keys];
    [self didChangeValuesForKeys:keys];
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

- (RACDisposable *)listenForNotification:(NSString *)name selector:(SEL)selector {
    @weakify(self);
    [[self listenForNotification:name] subscribeNext:^(NSNotification *note) {
        @strongify(self);
        [self performSelector:selector withObject:note];
    }];
}

- (RACSignal *)listenForNotification:(NSString *)name {
    return [self listenForNotification:name object:nil];
}

- (RACSignal *)listenForNotification:(NSString *)name object:(id)object {
    return [self listenForNotification:name object:object notificationCenter:[NSNotificationCenter defaultCenter]];
}

- (RACSignal *)listenForNotification:(NSString *)name
                              object:(id)object
                  notificationCenter:(NSNotificationCenter *)notificationCenter {
    return [[notificationCenter rac_addObserverForName:name object:object]
            takeUntil:self.rac_willDeallocSignal];
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

+ (void)performSelector:(SEL)sel withDelay:(NSTimeInterval)delay {
    [self performBlock:^{
        objc_msgSend(self, sel);
    } afterDelay:delay];
}

@end


