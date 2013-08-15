//
//  NSFetchedResultsController+CLToolkit.h
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#if TARGETING_IOS

#import "CoreData.h"

@interface NSFetchedResultsController (CLToolkit) <NSFetchedResultsControllerDelegate>

- (RACSignal *)onWillChangeContent;
- (RACSignal *)onDidChangeContent;
- (RACSignal *)onChangeObject; // Sends tuple (object, indexPath, changeType, newIndexPath)
- (RACSignal *)onChangeSection; // Sends tuple (sectionInfo, sectionIndex, changeType)

- (RACDisposable *)autoUpdateTableView:(UITableView *)tableView animated:(BOOL)animated;

@end

#endif