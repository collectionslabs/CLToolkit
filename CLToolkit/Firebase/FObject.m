//
//  FObject.m
//  Collections
//
//  Created by Tony Xiao on 4/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <Base64/MF_Base64Additions.h>
#import "FObject.h"

#ifndef FB
#define FB [[FNode alloc] initWithUrl:@"https://dbname.firebaseio.com"]
#endif

#define RESERVED_KEYS $set(@"fPath")

@implementation FObject {
    RACDisposable *_disposable;
}

@synthesize ref = _ref;
@dynamic fPath;

- (FNode *)ref { return _ref ?: (self.fPath ? _ref = FB[self.fPath] : nil); }

#pragma mark Two Way Real-Time Sync with Firebase

- (void)bindFirebase {
    NSParameterAssert(self.ref);
    if (_disposable)
        return;
    
    LogDebug(@"Binding firebase %@", self.fPath);
    
    Firebase *ref = self.ref;
    NSMutableArray *disposables = [NSMutableArray array];
    
    // Attributes
    for (NSAttributeDescription *attr in self.entity.attributesByName.allValues) {
        if (attr.isTransient || [RESERVED_KEYS containsObject:attr.name])
            continue;
        
        // Firebase -> CoreData
        [disposables addObject:[[ref[attr.name] rac_signalWithInitialValueForKeyPath:@"currentValue"] subscribeNext:^(id value) {
            if (!self->_disposable) return; // Firebase remove observer bug
            
            value = [attr reverseTransformedValue:value];
            if (value != [self valueForKey:attr.name] && ![value isEqual:[self valueForKey:attr.name]])
                [self setValue:value forKey:attr.name];
        }]];
        
        
        // CoreData -> Firebase
        [disposables addObject:[[self rac_signalForKeyPath:attr.name] subscribeNext:^(id x) {
            NSAssert(self.isFault == NO, @"Should never get here if object is faulted");
            ref[attr.name] = [attr transformedValue:[self valueForKey:attr.name]];
        }]];
    }
    
    // To-One Relationships
    for (NSRelationshipDescription *rel in self.entity.toOneRelationshipsByName.allValues) {
        if (rel.isTransient || rel.isInverse) continue;

        // Firebase -> CoreData
        [disposables addObject:[[ref[rel.name] rac_signalWithInitialValueForKeyPath:@"currentValue"] subscribeNext:^(id value) {
            if (!self->_disposable) return; // Firebase remove observer bug
            LogDebug(@"Setting %@ %@[toOne] = %@", self.fPath, rel.name, value);
            if (value != nil)
                value = [[self class] findByFPath:value inContext:self.managedObjectContext createIfMissing:YES];
            [self setValue:value forKey:rel.name];
        }]];
        
        // CoreData -> Firebase
        [disposables addObject:[[self rac_signalForKeyPath:rel.name] subscribeNext:^(id x) {
            NSAssert(self.isFault == NO, @"Should never get here if object is faulted");
            LogDebug(@"Ref Setting %@ %@[toOne] = %@", self.fPath, rel.name, [[self valueForKey:rel.name] valueForKey:@"fPath"]);
            ref[rel.name] = [[self valueForKey:rel.name] fPath];
        }]];
    }
    
    // To-Many Unordered Relationships
    for (NSRelationshipDescription *rel in self.entity.toManyUnorderedRelationshipsByName.allValues) {
        if (rel.isTransient || rel.isInverse) continue;
        // Firebase -> CoreData
        [disposables addObject:[[ref[rel.name] onEvents:@[@(FEventTypeChildAdded), @(FEventTypeChildRemoved)]] subscribeNext:^(RACTuple *tuple) {
            if (!self->_disposable) return; // Firebase remove observer bug

            FObject *obj = [[self class] findByFPath:FUnescapeName([tuple.first name]) inContext:self.managedObjectContext];
            NSMutableSet *relationship = [self mutableSetValueForKey:rel.name];
            switch ([tuple.third intValue]) {
                case FEventTypeChildAdded:
                    obj = obj ?: [[self class] findByFPath:FUnescapeName([tuple.first name])
                                                 inContext:self.managedObjectContext
                                           createIfMissing:YES];
                    LogDebug(@"Adding %@ %@[toMany] obj %@", self.fPath, rel.name, obj.fPath);
                    [relationship addObject:obj];
                    break;
                case FEventTypeChildRemoved:
                    if (obj) {
                        LogDebug(@"Removing %@ %@[toMany] obj %@", self.fPath, rel.name, obj.fPath);
                        [relationship removeObject:obj];
                    }
            }
        }]];
        
        // CoreData -> Firebase
        [disposables addObject:[[self rac_changeSignalForKeyPath:rel.name options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew] subscribeNext:^(NSDictionary *change) {
            NSAssert(self.isFault == NO, @"Should never get here if object is faulted");
            for (FObject *removed in $safeNull(change[NSKeyValueChangeOldKey])) {
                LogDebug(@"Ref Removing %@ %@[toMany] obj %@", self.fPath, rel.name, removed.fPath);
                ref[rel.name][FEscapeName(removed.fPath)] = nil;
            }
            for (FObject *inserted in $safeNull(change[NSKeyValueChangeNewKey])) {
                LogDebug(@"Ref Adding %@ %@[toMany] obj %@", self.fPath, rel.name, inserted.fPath);
                ref[rel.name][FEscapeName(inserted.fPath)] = @YES;
            }
        }]];
    }
    
    // To-Many Ordered Relationships
    for (NSRelationshipDescription *rel in self.entity.toManyOrderedRelationshipsByName.allValues) {
        if (rel.isTransient || rel.isInverse) continue;
        // Firebase -> CoreData
        [disposables addObject:[[ref[rel.name] onEvents:@[@(FEventTypeChildAdded), @(FEventTypeChildMoved), @(FEventTypeChildRemoved)]] subscribeNext:^(RACTuple *tuple) {
            if (!self->_disposable) return; // Firebase remove observer bug
            
            FObject *obj = [[self class] findByFPath:FUnescapeName([tuple.first name]) inContext:self.managedObjectContext];
            FObject *prevObj = [[self class] findByFPath:FUnescapeName(tuple.second) inContext:self.managedObjectContext];
            NSMutableOrderedSet *relationship = [self mutableOrderedSetValueForKey:rel.name];
            
            switch ([tuple.third intValue]) {
                case FEventTypeChildAdded: {
                    obj = obj ?: [[self class] findByFPath:FUnescapeName([tuple.first name])
                                                inContext:self.managedObjectContext
                                          createIfMissing:YES];
                    NSInteger prevIndex = prevObj ? [relationship indexOfObject:prevObj] : NSNotFound;
                    [relationship insertObject:obj atIndex:prevIndex == NSNotFound ? 0 : prevIndex + 1];
                    break;
                }
                case FEventTypeChildRemoved:
                    [relationship removeObject:obj];
                    break;
                case FEventTypeChildMoved: {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[relationship indexOfObject:obj]];
                    [relationship moveObjectsAtIndexes:indexSet toIndex:[relationship indexOfObject:prevObj] + 1];
                    break;
                }
            }
        }]];
        
        // CoreData -> Firebase
        [disposables addObject:[[self rac_changeSignalForKeyPath:rel.name options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew] subscribeNext:^
         (NSDictionary *change) {
             NSAssert(self.isFault == NO, @"Should never get here if object is faulted");
             // TODO: Handle persistence of object order in the relationship
             for (FObject *removed in $safeNull(change[NSKeyValueChangeOldKey])) {
                 ref[rel.name][FEscapeName(removed.fPath)] = nil;
             }
             for (FObject *inserted in $safeNull(change[NSKeyValueChangeNewKey])) {
                 ref[rel.name][FEscapeName(inserted.fPath)] = @YES;
             }
         }]];
    }
    
    // Object Removal & Faulting state management
    [disposables addObject:[[ref onValue] subscribeNext:^(FDataSnapshot *snap) {
        if (!self->_disposable) return; // Firebase remove observer bug
                
        if (snap.value == [NSNull null])
            [self deleteEntity];
    }]];
    [disposables addObject:[[self onPrepareDelete] subscribeNext:^(id x) {
        [self.ref removeValue];
    }]];
    
    _disposable = [[RACCompoundDisposable compoundDisposableWithDisposables:disposables] asScopedDisposable];
}

- (void)unbindFirebase {
    LogDebug(@"Unbinding firebase %@", self.ref.pathString);
    [_disposable dispose];
    _disposable = nil;
}

- (RACSignal *)loadFromFirebase {
    NSParameterAssert(self.ref);
    return [RACSignal empty]; // Using bindFirebase to loadFromFirebase is good enough for now.
}

- (RACSignal *)saveToFirebase {
    NSParameterAssert(self.ref);
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    for (NSAttributeDescription *attr in self.entity.attributesByName.allValues)
        if (!attr.isTransient && ![RESERVED_KEYS containsObject:attr.name])
            [properties setValue:[attr transformedValue:[self valueForKey:attr.name]] forKey:attr.name];
    
    for (NSRelationshipDescription *rel in self.entity.toOneRelationshipsByName.allValues)
        if (!rel.isTransient)
            [properties setValue:[[self valueForKey:rel.name] fPath] forKey:rel.name];
    
    for (NSRelationshipDescription *rel in self.entity.toManyRelationshipsByName.allValues) {
        if (!rel.isTransient) {
            NSMutableDictionary *value = [NSMutableDictionary dictionary];
            for (FObject *object in [self valueForKey:rel.name])
                [value setValue:@YES forKey:FEscapeName(object.fPath)];
            [properties setValue:value forKey:rel.name];
        }
    }
    
    return [self.ref updateChildren:properties];
}

- (void)generateFPathIfMissing {
    if (!self.fPath) {
        NSString *entityName = [[self.entity.name.lowercaseString $append:@"s"] sliceFrom:1];
        self.ref = [FB[entityName] childByAutoId];
        self.fPath = self.ref.pathString;
    }
}

#pragma mark - Life Cycle Management

- (void)commonInit {
    if (self.fPath)
        [self bindFirebase];
}

- (void)didSave {
    [super didSave];
    if (!self.isDeleted && self.managedObjectContext && !self.fPath) {
        [self generateFPathIfMissing];
        [[self saveToFirebase] subscribeCompleted:^{
            [self bindFirebase];
        }];
    }
}

- (void)didTurnIntoFault {
    [super didTurnIntoFault];
    [self unbindFirebase];
}

#pragma mark Class Methods

+ (instancetype)findByFPath:(NSString *)fPath {
    return [self findByFPath:fPath inContext:[NSManagedObjectContext defaultContext]];
}

+ (instancetype)findByFPath:(NSString *)fPath inContext:(NSManagedObjectContext *)context {
    return [self findByFPath:fPath inContext:context createIfMissing:NO];
}

+ (instancetype)findByFPath:(NSString *)fPath inContext:(NSManagedObjectContext *)context createIfMissing:(BOOL)create {
    if (!fPath)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity  = [self entityForFPath:fPath];
    fetchRequest.predicate = $pred(@"fPath == %@", fPath);
    fetchRequest.fetchLimit = 1;
    
    FObject *object = [[context executeFetchRequest:fetchRequest error:NULL] lastObject];
    if (!object && create) {
        object = (id)[[NSManagedObject alloc] initWithEntity:fetchRequest.entity insertIntoManagedObjectContext:nil];
        object.fPath = fPath;
        [context insertObject:object];
    }
    return object;
}

+ (NSEntityDescription *)entityForFPath:(NSString *)fPath {
    for (NSEntityDescription *entity in [[NSManagedObjectModel defaultManagedObjectModel] entities]) {
        NSString *entityName = [[entity.name.lowercaseString $append:@"s"] sliceFrom:1];
        if ([[fPath sliceFrom:1] hasPrefix:entityName])
            return entity;
    }
    return nil;
}

@end


