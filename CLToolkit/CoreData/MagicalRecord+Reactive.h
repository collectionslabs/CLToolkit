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

- (RACSignal *)performBlockAndSave:(void (^)())block;
- (RACSignal *)saveToPersistentStore;
- (RACSignal *)saveOnlySelf;
- (RACSignal *)saveWithOptions:(MRSaveContextOptions)mask;

@end

#if TARGETING_IOS

@interface NSFetchedResultsController (CLToolkit) <NSFetchedResultsControllerDelegate>

- (RACSignal *)onWillChangeContent;
- (RACSignal *)onDidChangeContent;
- (RACSignal *)onChangeObject; // Sends tuple (object, indexPath, changeType, newIndexPath)
- (RACSignal *)onChangeSection; // Sends tuple (sectionInfo, sectionIndex, changeType)

- (RACDisposable *)autoUpdateTableView:(UITableView *)tableView animated:(BOOL)animated;

@end

#endif