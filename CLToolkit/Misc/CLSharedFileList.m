//
//  CLSharedFileList.m
//  Collections
//
//  Created by Tony Xiao on 3/13/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "CLSharedFileList.h"

#if TARGETING_OSX

typedef void (^SharedFileListCallbackBlock)(LSSharedFileListRef inList);

static void SharedFileListCallbackHelper(LSSharedFileListRef inList, void *context) {
    SharedFileListCallbackBlock block = (__bridge SharedFileListCallbackBlock)context;
    block(inList);
}

static void SharedFileListAddObserverWithBlock(LSSharedFileListRef inList, SharedFileListCallbackBlock block) {
    LSSharedFileListAddObserver(inList, CFRunLoopGetMain(), kCFRunLoopDefaultMode,
                                &SharedFileListCallbackHelper, (__bridge void *)block);
}

static void SharedFileListRemoveObservingBlock(LSSharedFileListRef inList, SharedFileListCallbackBlock block) {
    LSSharedFileListRemoveObserver(inList, CFRunLoopGetMain(), kCFRunLoopDefaultMode,
                                   &SharedFileListCallbackHelper, (__bridge void *)block);
}

@implementation CLSharedFileList {
    SharedFileListCallbackBlock _listChangedBlock;
}

@synthesize lsList = _lsList;

- (id)initWithListName:(CFStringRef)listName {
    self = [super init];
    if (self) {
        _lsList = LSSharedFileListCreate(NULL, listName, NULL);
        _listChanged = [RACSubject subject];
        __block CLSharedFileList *this = self;
        _listChangedBlock = ^void(LSSharedFileListRef inList) {
            [(RACSubject *)this.listChanged sendNext:nil];
        };
        SharedFileListAddObserverWithBlock(_lsList, _listChangedBlock);
    }
    return self;
}

- (void)dealloc {
    if (_lsList) {
        SharedFileListRemoveObservingBlock(_lsList, _listChangedBlock);
        CFRelease(_lsList);
        _lsList = NULL;
    }
}

#pragma mark Low Level API

- (NSArray *)itemsSnapshot {
    return (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(self.lsList, NULL);
}

- (LSSharedFileListItemRef)itemRefForURL:(NSURL *)url {
    LSSharedFileListItemRef locatedItem = nil;
    NSArray *items = [self itemsSnapshot];
    CFURLRef itemUrl = NULL;
    
    for (int i = 0; i < [items count]; i++) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)[items objectAtIndex:i];
        UInt32 flags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        if (LSSharedFileListItemResolve(item, flags, &itemUrl, NULL) == noErr) {
            if ([url isEqual:(__bridge NSURL *)itemUrl])
                locatedItem = item;
            if (itemUrl)
                CFRelease(itemUrl);
        }
        
    }
    
    if (locatedItem)
        CFRetain(locatedItem);
    
    return locatedItem;
}

- (LSSharedFileListItemRef)insertUrl:(NSURL *)url name:(NSString *)name icon:(NSImage *)icon props:(NSDictionary *)properties after:(LSSharedFileListItemRef)afterItem {
    return LSSharedFileListInsertItemURL(self.lsList,
                                         afterItem,
                                         (__bridge CFStringRef)name,
                                         [icon iconRefRepresentation],
                                         (__bridge CFURLRef)url,
                                         (__bridge CFDictionaryRef)properties,
                                         NULL);
}

#pragma mark High Level API

- (void)addURL:(NSURL *)url {
    if (![self containsURL:url]) {
        LSSharedFileListItemRef item = [self insertUrl:url name:url.lastPathComponent icon:nil props:nil after:kLSSharedFileListItemBeforeFirst];
        if (item)
            CFRelease(item);
    }
}

- (BOOL)containsURL:(NSURL *)url {
    LSSharedFileListItemRef item = [self itemRefForURL:url];
    BOOL contains = (item != nil);
    if (item)
        CFRelease(item);
    return contains;
}


- (void)removeURL:(NSURL *)url {
    LSSharedFileListItemRef item = [self itemRefForURL:url];
    if (item) {
        LSSharedFileListItemRemove(self.lsList, item);
        CFRelease(item);
    }
}

- (void)setValue:(id)value forProperty:(CFStringRef)name ofItemWithURL:(NSURL *)url {
    LSSharedFileListItemRef item = [self itemRefForURL:url];
    if (item) {
        LSSharedFileListItemSetProperty(item, name, (__bridge CFTypeRef)value);
        CFRelease(item);
    }
}


#pragma mark Class Methods

+ (BOOL)isLaunchAtStartup {
    CLSharedFileList *list = [[self alloc] initWithListName:kLSSharedFileListSessionLoginItems];
    return [list containsURL:[[NSBundle mainBundle] bundleURL]];
}

+ (void)setLaunchAtStartup:(BOOL)launch {
    CLSharedFileList *list = [[self alloc] initWithListName:kLSSharedFileListSessionLoginItems];
    NSURL *url = [[NSBundle mainBundle] bundleURL];
    launch ? [list addURL:url] : [list removeURL:url];
}

@end

#endif
