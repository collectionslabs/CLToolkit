//
//  MagicalRecord+Reactive.h
//  Collections
//
//  Created by Tony Xiao on 7/11/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "CoreData.h"

@interface MagicalRecord (Reactive)

+ (RACSignal *)rac_saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
+ (RACSignal *)rac_saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block onQueue:(NSOperationQueue *)queue;
+ (RACSignal *)rac_saveUsingCurrentThreadContextWithBlock:(void (^)(NSManagedObjectContext *localContext))block;

@end

@interface NSManagedObjectContext (Reactive)

- (RACSignal *)performBlockWithCompletion:(void (^)())block;
- (RACSignal *)performBlockAndSave:(void (^)())block;
- (RACSignal *)saveToPersistentStore;
- (RACSignal *)saveOnlySelf;
- (RACSignal *)saveWithOptions:(MRSaveContextOptions)mask;

+ (void)MR_setContextForCurrentThread:(NSManagedObjectContext *)context;

@end
