//
//  NSManagedObjectContext+MRExtensions.h
//  Collections
//
//  Created by Tony Xiao on 7/13/13.
//  Copyright (c) 2013 Collections. All rights reserved.
//

#import "CoreData.h"

@interface NSManagedObjectContext (MRExtensions)

+ (void)MR_setContextForCurrentThread:(NSManagedObjectContext *)context;

@end
