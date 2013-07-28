//
//  NSManagedObjectContext+MRExtensions.m
//  Collections
//
//  Created by Tony Xiao on 7/13/13.
//  Copyright (c) 2013 Collections. All rights reserved.
//

#import "NSManagedObjectContext+MRExtensions.h"

@implementation NSManagedObjectContext (MRExtensions)

static NSString const * kMagicalRecordManagedObjectContextKey = @"MagicalRecord_NSManagedObjectContextForThreadKey";

+ (void)MR_setContextForCurrentThread:(NSManagedObjectContext *)context {
	if ([NSThread isMainThread]) {
        [(id)self performSelector:@selector(MR_setDefaultContext:) withObject:context];
	} else {
		NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        threadDict[kMagicalRecordManagedObjectContextKey] = context;
	}
}

@end
