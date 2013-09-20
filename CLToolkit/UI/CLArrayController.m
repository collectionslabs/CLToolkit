//
//  CLArrayController.m
//  Pods
//
//  Created by Tony Xiao on 9/18/13.
//
//

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

@property (nonatomic, weak) CLArrayController *arrayController;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) NSRange range;

@end

@implementation CLSectionInfo

- (id)initWithName:(NSString *)name arrayController:(CLArrayController *)arrayController {
    if (self = [super init]) {
        _name = name;
        _arrayController = arrayController;
        _range = NSMakeRange(0, arrayController.arrangedObjects.count);
    }
    return self;
}

- (NSArray *)objects {
    return [self.arrayController.arrangedObjects subarrayWithRange:self.range];
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
        [[RACSignal merge:@[RACAbleWithStart(content),
                            RACAble(filterPredicate),
                            RACAble(filterBlock),
                            RACAble(sortDescriptors),
                            RACAble(sectionNameKeypath)]] subscribeNext:^(id x) {
            @strongify(self);
            [self rearrangeObjects];
        }];
    }
    return self;
}

- (void)rearrangeObjects {
    NSMutableArray *objects = [[self.content sortedArrayUsingDescriptors:self.sortDescriptors] mutableCopy];
    if (self.filterPredicate)
        [objects filterUsingPredicate:self.filterPredicate];
    if (self.filterBlock)
        [objects performSelect:self.filterBlock];
    
    self.arrangedObjects = objects;
    if (self.sectionNameKeypath.length) {
        __block NSString *currentName = nil;
        __block NSUInteger currentIndex = 0;
        self.sections = [self.arrangedObjects reduce:@[] withBlock:^id(NSArray *sections, id obj) {
            NSString *name = [obj valueForKeyPath:self.sectionNameKeypath];
            if (![name isEqualToString:currentName]) {
                CLSectionInfo *lastSection = sections.lastObject;
                if (lastSection) {
                    lastSection.range = NSMakeRange(lastSection.range.location,
                                                    currentIndex - lastSection.range.location);
                }
                CLSectionInfo *section = [[CLSectionInfo alloc] initWithName:name arrayController:self];
                section.range = NSMakeRange(currentIndex, self.arrangedObjects.count - currentIndex);
                sections = [sections arrayByAddingObject:section];
            }
            currentName = name;
            currentIndex++;
            return sections;
        }];
    } else {
        self.sections = @[[[CLSectionInfo alloc] initWithName:nil arrayController:self]];
    }
    [_rearrangeSignal sendNext:self.sections];
}

#pragma mark Accessors

- (NSArray *)selectedObjects {
    return [self.arrangedObjects objectsAtIndexes:self.selectedIndexes];
}

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
    [tableView.dynamicDelegate setArrayController:self];
    [tableView.dynamicDataSource setArrayController:self];
    if (reload)
        [tableView reloadData];
}

- (void)unbindFromTableView:(UITableView *)tableView reloadData:(BOOL)reload {
    [tableView.dynamicDelegate setArrayController:nil];
    [tableView.dynamicDataSource setArrayController:nil];
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
