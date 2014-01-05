//
//  CLArrayController.h
//  CLToolkit
//
//  Created by Tony Xiao on 9/18/13.
//
//

#import <Foundation/Foundation.h>

/**
 *  @param obj object from content
 *  @return BOOL indicacating whether object passes test
 */
typedef BOOL (^CLFilterBlock)(id obj);

/**
 *  @param obj object from content
 *  @return object to be used as section key
 */
typedef id<NSCopying> (^CLSectionKeyBlock)(id obj);

/**
 *  @param sectionKey section key, return value of `sectionKeyBlock`
 *  @return String to be displayed as section name
 */
typedef NSString *(^CLSectionNameBlock)(id<NSCopying> sectionKey);


#pragma mark -

@interface CLSectionInfo : NSObject

@property (nonatomic, readonly) id<NSCopying> key;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) NSRange range;

@end

#pragma mark -

@interface CLArrayController : NSObject

// Content
@property (nonatomic, strong) id content;
@property (nonatomic, readonly) NSArray *arrangedObjects;
@property (nonatomic, readonly) BOOL isRearranging;

// Sectioning
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, copy) CLSectionKeyBlock sectionKeyBlock;
@property (nonatomic, copy) CLSectionNameBlock sectionNameBlock;
@property (nonatomic, strong) NSArray *sectionSortDescriptors;

// Filtering
@property (nonatomic, copy) CLFilterBlock filterBlock;

// Sorting
@property (nonatomic, strong) NSArray *sortDescriptors;

// Selection
@property (nonatomic, readonly) NSIndexSet *selectedIndexes;
@property (nonatomic, readonly) NSArray *selectedObjects;

- (id)initWithContent:(id)content; // Content can be either NSArray or NSSet

- (void)rearrangeObjects;

// Section Object Access

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
