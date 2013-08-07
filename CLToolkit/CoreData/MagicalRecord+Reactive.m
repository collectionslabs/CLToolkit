//
//  MagicalRecord+Reactive.m
//  Collections
//
//  Created by Tony Xiao on 7/11/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "RACSignalOperation.h"
#import "MagicalRecord+Reactive.h"

typedef void (^MRCompletionHandler)(BOOL success, NSError *error);

@implementation RACSubject (Completion)

- (MRCompletionHandler)mr_completionBlock {
    @weakify(self);
    return ^(BOOL success, NSError *error) {
        @strongify(self);
        (success || !error) ? [self sendCompleted] : [self sendError:error];
    };
}

+ (RACSubject *)mr_subject:(void (^)(MRCompletionHandler completionBlock))block; {
    RACSubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
    block(subject.mr_completionBlock);
    return subject;
}

@end

@implementation MagicalRecord (Reactive)

+ (RACSignal *)rac_saveWithBlock:(void (^)(NSManagedObjectContext *))block {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveWithBlock:block completion:completionBlock];
    }];
}

+ (RACSignal *)rac_saveWithBlock:(void (^)(NSManagedObjectContext *))block onQueue:(NSOperationQueue *)queue {
    RACSubject *subject = [RACReplaySubject subject];
    @weakify(self);
    
    [queue addOperation:[CLAsyncOperation operationWithBlock:^(CLAsyncOperation *operation) {
        @strongify(self);
        [self saveWithBlock:block completion:^(BOOL success, NSError *error) {
            [operation finish];
            success ? [subject sendCompleted] : [subject sendError:error];
        }];
    }]];
    return subject;
}

+ (RACSignal *)rac_saveUsingCurrentThreadContextWithBlock:(void (^)(NSManagedObjectContext *localContext))block {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveUsingCurrentThreadContextWithBlock:block completion:completionBlock];
    }];
}

@end


@implementation NSManagedObjectContext (Reactive)

- (RACSignal *)performBlockAndSave:(void (^)())block {
    RACSubject *subject = [RACSubject subjectWithSelector:_cmd];
    [self performBlock:^{
        block();
        [[self saveToPersistentStore] subscribe:subject];
    }];
    return subject;
}

- (RACSignal *)saveToPersistentStore {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveToPersistentStoreWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveOnlySelf {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveOnlySelfWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveWithOptions:(MRSaveContextOptions)mask {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        return [self saveWithOptions:mask completion:completionBlock];
    }];
}

@end

#if TARGETING_IOS

@implementation NSFetchedResultsController (CLToolkit)

- (RACDisposable *)autoUpdateTableView:(UITableView *)tableView animated:(BOOL)animated {
    @weakify(tableView);
    return [RACCompoundDisposable compoundDisposableWithDisposables:@[
    [[self onWillChangeContent] subscribeNext:^(id x) {
        if (animated)
            [tableView beginUpdates];
    }],
    [[self onDidChangeContent] subscribeNext:^(id x) {
        if (animated)
            [tableView endUpdates];
        else
            [tableView reloadData];
    }],
    [[self onChangeObject] subscribeNext:^(RACTuple *tuple) {
        if (!animated)
            return;
        RACTupleUnpack(id obj, NSIndexPath *indexPath, NSNumber *type, NSIndexPath *newIndexPath) = tuple;
        switch (type.intValue) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }],
    [[self onChangeSection] subscribeNext:^(RACTuple *tuple) {
        if (!animated)
            return;
        RACTupleUnpack(id<NSFetchedResultsSectionInfo> sectionInfo, NSNumber *sectionIndex, NSNumber *type) = tuple;
        switch (type.intValue) {
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:
                                                sectionIndex] withRowAnimation:
                 UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:
                                                sectionIndex] withRowAnimation:
                 UITableViewRowAnimationFade];
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
    [(RACSubject *)self.onChangeSection sendNext:RACTuplePack(sectionInfo, @(sectionIndex), @(type))];
}

@end

#endif