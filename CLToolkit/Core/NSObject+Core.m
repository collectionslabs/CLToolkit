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

+ (void)performSelector:(SEL)sel withDelay:(NSTimeInterval)delay {
    [self performBlock:^{
        objc_msgSend(self, sel);
    } afterDelay:delay];
}

@end

@implementation UIViewController (Core)

- (void)cl_logDescendants:(NSInteger )indent {
    NSString *padding = [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0];
    NSLog(@"%@%@", padding, self.description);
    if (self.childViewControllers.count) {
        NSLog(@"%@  children:", padding);
        [self.childViewControllers each:^(UIViewController *viewController) {
            [viewController cl_logDescendants:indent + 2];
        }];
    }
    if (self.presentedViewController) {
        NSLog(@"%@  presented:", padding);
        [self.presentedViewController cl_logDescendants:indent + 2];
    }
}

- (void)cl_logDescendants {
    [self cl_logDescendants:0];
}

@end

@implementation UISearchBar (Core)

- (UITextField *)cl_searchField {
    return [[self.subviews select:^BOOL(UIView *view) {
        return [view isKindOfClass:[UITextField class]];
    }] lastObject];
}

- (UIActivityIndicatorView *)cl_spinner {
    return [[self.cl_searchField.leftView.subviews select:^BOOL(UIView *view) {
        return [view isKindOfClass:[UIActivityIndicatorView class]];
    }] lastObject];
}

- (void)startActivity {
    UIActivityIndicatorView *spinner = [self cl_spinner];
    if (!spinner) {
        UITextField *searchField = [self cl_searchField];
        CGRect bounds = searchField.leftView.bounds;
        NSParameterAssert(searchField);
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(bounds.origin.x + bounds.size.width/2,
                                     bounds.origin.y + bounds.size.height/2);
        spinner.hidesWhenStopped = YES;
        spinner.backgroundColor = [UIColor whiteColor];
        [searchField.leftView addSubview:spinner];
    }
    [spinner startAnimating];
}

- (void)stopActivity {
    [[self cl_spinner] stopAnimating];
}

@end


@implementation UIView (CLToolkit)

- (void)animateWithKeyboard:(NSDictionary *)keyboardInfo block:(void (^)(CGRect keyboardEndFrame))block {
    NSTimeInterval animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardEndFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardEndFrame = [self convertRect:keyboardEndFrame fromView:nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    block(keyboardEndFrame);
    [UIView commitAnimations];
}

@end