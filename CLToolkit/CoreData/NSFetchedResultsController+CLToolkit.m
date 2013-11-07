//
//  NSFetchedResultsController+CLToolkit.m
//  CLToolkit
//
//  Created by Tony Xiao on 8/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//


#import "NSFetchedResultsController+CLToolkit.h"

#if TARGETING_IOS

@implementation NSFetchedResultsController (CLToolkit)

- (RACDisposable *)autoUpdateTableView:(UITableView *)tableView animated:(BOOL)animated {
    if (!self.fetchedObjects)
        [self performFetch:NULL];
    [tableView reloadData];
    @weakify(tableView);
    return [RACCompoundDisposable compoundDisposableWithDisposables:@[
            [[self onWillChangeContent] subscribeNext:^(id x) {
        // LogTrace(@"%@(%@) onWillChangeContent", self, self.fetchRequest.entityName);
        @strongify(tableView);
        if (animated)
            [tableView beginUpdates];
    }],
    [[self onDidChangeContent] subscribeNext:^(id x) {
        // LogTrace(@"%@(%@) onDidChangeContent", self, self.fetchRequest.entityName);
        @strongify(tableView);
        if (animated)
            [tableView endUpdates];
        else
            [tableView reloadData];
    }],
    [[self onChangeObject] subscribeNext:^(RACTuple *tuple) {
        @strongify(tableView);
        if (!animated)
            return;
        RACTupleUnpack(id obj __unused, NSIndexPath *indexPath, NSNumber *type, NSIndexPath *newIndexPath) = tuple;
        switch (type.intValue) {
            case NSFetchedResultsChangeInsert:
                // LogTrace(@"%@(%@) will insert %@", self, self.fetchRequest.entityName, newIndexPath);
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                // LogTrace(@"%@(%@) will delete %@", self, self.fetchRequest.entityName, indexPath);
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
                // LogTrace(@"%@(%@) will move from %@ to %@", self, self.fetchRequest.entityName, indexPath, newIndexPath);
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                // LogTrace(@"%@(%@) will update %@", self, self.fetchRequest.entityName, indexPath);
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }],
    [[self onChangeSection] subscribeNext:^(RACTuple *tuple) {
        @strongify(tableView);
        if (!animated)
            return;
        RACTupleUnpack(id<NSFetchedResultsSectionInfo> sectionInfo __unused, NSNumber *sectionIndex, NSNumber *type) = tuple;
        switch (type.intValue) {
            case NSFetchedResultsChangeInsert:
                // LogTrace(@"%@(%@) will insert section %@", self, self.fetchRequest.entityName, sectionIndex);
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue]
                         withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                // LogTrace(@"%@(%@) will delete section %@", self, self.fetchRequest.entityName, sectionIndex);
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.integerValue]
                         withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }]]];
}

#pragma mark Accessors

- (RACSignal *)onWillChangeContent {
    self.delegate = self;
    return [self associatedValueForKey:__func__ setDefault:[RACSubject subject]];
}

- (RACSignal *)onDidChangeContent {
    self.delegate = self;
    return [self associatedValueForKey:__func__ setDefault:[RACSubject subject]];
}

- (RACSignal *)onChangeObject {
    self.delegate = self;
    return [self associatedValueForKey:__func__ setDefault:[RACSubject subject]];
}

- (RACSignal *)onChangeSection {
    self.delegate = self;
    return [self associatedValueForKey:__func__ setDefault:[RACSubject subject]];
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [(RACSubject *)self.onWillChangeContent sendNext:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [(RACSubject *)self.onDidChangeContent sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    [(RACSubject *)self.onChangeObject sendNext:RACTuplePack(anObject, indexPath, @(type), newIndexPath)];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    [(RACSubject *)self.onChangeSection sendNext:RACTuplePack((id)sectionInfo, @(sectionIndex), @(type))];
}

@end

#endif