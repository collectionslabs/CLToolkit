//
//  CLArrayController.m
//  CLToolkit
//
//  Created by Tony Xiao on 9/18/13.
//
//

#import <BlocksKit/A2DynamicDelegate.h>
#import "UI.h"
#import "CLArrayController.h"

@interface A2DynamicUITableViewDelegate : A2DynamicDelegate <UITableViewDelegate>

@property (nonatomic, weak) CLArrayController *arrayController;

@end

@implementation A2DynamicUITableViewDelegate

@end

#pragma mark -

@interface A2DynamicUITableViewDataSource : A2DynamicDelegate <UITableViewDataSource>

@property (nonatomic, weak) CLArrayController *arrayController;

@end

@implementation A2DynamicUITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrayController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayController.sections[section] range].length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.realDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end

#pragma mark - Public Classes

@interface CLSectionInfo ()

@property (nonatomic, strong) id<NSCopying> key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, assign) NSRange range;

@end

@implementation CLSectionInfo

- (id)init {
    if (self = [super init]) {
        _objects = [[NSMutableArray alloc] init];
        _range = NSMakeRange(0, 0);
    }
    return self;
}

@end

#pragma mark -

@interface CLArrayController()

@property (nonatomic, strong, readwrite) NSArray *sections;
@property (nonatomic, strong, readwrite) NSArray *arrangedObjects;

@end

@implementation CLArrayController {
    RACSubject *_rearrangeSignal;
}

- (id)init {
    return [self initWithContent:nil];
}

- (id)initWithContent:(id)content {
    if (self = [super init]) {
        _content = content;
        _selectedIndexes = [[NSMutableIndexSet alloc] init];
        _rearrangeSignal = [RACSubject subject];
        @weakify(self);
        [[RACSignal merge:@[[RACObserve(self, content) skip:1],
                            [RACObserve(self, sectionKeyBlock) skip:1],
                            [RACObserve(self, sectionNameBlock) skip:1], // Rather inefficient, oh well
                            [RACObserve(self, sectionSortDescriptors) skip:1],
                            [RACObserve(self, filterBlock) skip:1],
                            [RACObserve(self, sortDescriptors) skip:1]]] subscribeNext:^(id x) {
            @strongify(self);
            [self rearrangeObjects];
        }];
        [self rearrangeObjects];
    }
    return self;
}

#pragma mark -

- (void)rearrangeWithSectionKey {
    NSParameterAssert(self.sectionKeyBlock);
    NSMutableArray *sortedObjects = [[NSMutableArray alloc] init];
    NSMutableArray *sortedSections = [[NSMutableArray alloc] init];
    NSMutableDictionary *sections = [[NSMutableDictionary alloc] init];
    
    // Obtain section information for all objects
    for (id object in [self.content copy]) {
        if (self.filterBlock && !self.filterBlock(object))
            continue;
        
        id sectionKey = self.sectionKeyBlock(object);
        CLSectionInfo *section = sections[sectionKey];
        if (!section) {
            section = [[CLSectionInfo alloc] init];
            section.key = sectionKey;
            section.name = self.sectionNameBlock ? self.sectionNameBlock(sectionKey) : [sectionKey description];
            sections[sectionKey] = section;
            [sortedSections addObject:section];
        }
        [(NSMutableArray *)section.objects addObject:object];
    }
    
    // Sort sections if needed
    if (self.sectionSortDescriptors.count)
        [sortedSections sortUsingDescriptors:self.sectionSortDescriptors];
    
    // Sort objects if needed then concatenate all objects into a single array
    for (CLSectionInfo *section in sortedSections) {
        // Sort objects if needed
        if (self.sortDescriptors.count)
            [(NSMutableArray *)section.objects sortUsingDescriptors:self.sortDescriptors];
        
        section.range = NSMakeRange(sortedObjects.count, section.objects.count);
        [sortedObjects addObjectsFromArray:section.objects];
    }
    
    self.sections = sortedSections;
    self.arrangedObjects = sortedObjects;
}

- (void)rearrangeWithoutSectionKey {
    NSParameterAssert(!self.sectionKeyBlock);
    
    NSMutableArray *sortedObjects = [[self.content sortedArrayUsingDescriptors:self.sortDescriptors] mutableCopy];
    if (self.filterBlock)
        [sortedObjects bk_performSelect:self.filterBlock];
    
    CLSectionInfo *section = [[CLSectionInfo alloc] init];
    section.range = NSMakeRange(0, sortedObjects.count);
    section.objects = sortedObjects;
    
    self.sections = @[section];
    self.arrangedObjects = sortedObjects;
}

- (void)rearrangeObjects {
    if (self.sectionKeyBlock) {
        [self rearrangeWithSectionKey];
    } else {
        [self rearrangeWithoutSectionKey];
    }
    [_rearrangeSignal sendNext:nil];
}

#pragma mark -

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(!indexPath || indexPath.length == 2);
    return [self.sections[indexPath.section] objects][indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self indexPathForIndex:[self.arrangedObjects indexOfObject:object]];
}

- (NSUInteger)indexForIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(!indexPath || indexPath.length == 2);
    if (indexPath.section < self.sections.count) {
        CLSectionInfo *section = self.sections[indexPath.section];
        if (indexPath.row < section.range.length)
            return section.range.location + indexPath.row;
    }
    return NSNotFound;
}

- (NSIndexPath *)indexPathForIndex:(NSUInteger)index {
    for (int i=0; i< self.sections.count; i++) {
        CLSectionInfo *section = self.sections[i];
        if (NSLocationInRange(index, section.range))
            return [NSIndexPath indexPathForRow:index - section.range.location inSection:i];
    }
    return nil;
}

#pragma mark Accessors

- (NSArray *)selectedObjects {
    return [self.arrangedObjects objectsAtIndexes:self.selectedIndexes];
}

#pragma mark Selections

- (void)selectAll {
    [self willChangeValueForKey:@keypath(self, selectedIndexes)];
    [(NSMutableIndexSet *)_selectedIndexes addIndexesInRange:NSMakeRange(0, self.arrangedObjects.count)];
    [self didChangeValueForKey:@keypath(self, selectedIndexes)];
}

- (void)deselectAll {
    [self willChangeValueForKey:@keypath(self, selectedIndexes)];
    [(NSMutableIndexSet *)_selectedIndexes removeAllIndexes];
    [self didChangeValueForKey:@keypath(self, selectedIndexes)];
}

- (void)selectIndex:(NSUInteger)index {
    [self willChangeValueForKey:@keypath(self, selectedIndexes)];
    [(NSMutableIndexSet *)_selectedIndexes addIndex:index];
    [self didChangeValueForKey:@keypath(self, selectedIndexes)];
}

- (void)deselectIndex:(NSUInteger)index {
    [self willChangeValueForKey:@keypath(self, selectedIndexes)];
    [(NSMutableIndexSet *)_selectedIndexes removeIndex:index];
    [self didChangeValueForKey:@keypath(self, selectedIndexes)];
}

- (void)toggleSelectionAtIndex:(NSUInteger)index {
    if (![_selectedIndexes containsIndex:index])
        [self selectIndex:index];
    else
        [self deselectIndex:index];
}

#pragma mark Bindings

- (void)bindToTableView:(UITableView *)tableView reloadData:(BOOL)reload {
    [tableView.bk_dynamicDelegate setArrayController:self];
    [tableView.bk_dynamicDataSource setArrayController:self];
    if (reload)
        [tableView reloadData];
}

- (void)unbindFromTableView:(UITableView *)tableView reloadData:(BOOL)reload {
    [tableView.bk_dynamicDelegate setArrayController:nil];
    [tableView.bk_dynamicDataSource setArrayController:nil];
    if (reload)
        [tableView reloadData];
}

+ (void)load {
    @autoreleasepool {
//        [UITableView registerDynamicDelegate];
//        [UITableView registerDynamicDataSource];
    }
}

@end
