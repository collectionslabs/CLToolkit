//
//  CLArrayController.h
//  Pods
//
//  Created by Tony Xiao on 9/18/13.
//
//

#import <Foundation/Foundation.h>

@interface CLSectionInfo : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) NSRange range;

@end

typedef BOOL (^CLFilterBlock)(id obj);

#pragma mark -

@interface CLArrayController : NSObject

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSArray *arrangedObjects;
@property (nonatomic, readonly) NSIndexSet *selectedIndexes;
@property (nonatomic, readonly) NSArray *selectedObjects;
@property (nonatomic, readonly) RACSignal *rearrangeSignal;

@property (nonatomic, strong) id content;
@property (nonatomic, strong) NSString *sectionNameKeypath;
// Filter
@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, copy) CLFilterBlock filterBlock;
// Sort
@property (nonatomic, strong) NSArray *sortDescriptors;

- (id)initWithContent:(id)content; // Content can be NSArray or NSSet

- (void)rearrangeObjects;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (NSUInteger)indexForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForIndex:(NSUInteger)index;

// Selection Management
- (void)selectAll;
- (void)deselectAll;
- (void)selectIndex:(NSUInteger)index;
- (void)deselectIndex:(NSUInteger)index;
- (void)toggleSelectionAtIndex:(NSUInteger)index;

- (void)bindToTableView:(UITableView *)tableView reloadData:(BOOL)reload;
- (void)unbindFromTableView:(UITableView *)tableView reloadData:(BOOL)reload;

@end

