//
//  NSFetchedResultsController+CLToolkit.h
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CoreData.h"

#if TARGETING_IOS

@interface NSFetchedResultsController (CLToolkit) <NSFetchedResultsControllerDelegate>

- (RACSignal *)onWillChangeContent;
- (RACSignal *)onDidChangeContent;
- (RACSignal *)onChangeObject; // Sends tuple (object, indexPath, changeType, newIndexPath)
- (RACSignal *)onChangeSection; // Sends tuple (sectionInfo, sectionIndex, changeType)

- (RACDisposable *)autoUpdateTableView:(UITableView *)tableView animated:(BOOL)animated;

@end

#endif