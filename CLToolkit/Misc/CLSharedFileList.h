//
//  CLSharedFileList.h
//  Collections
//
//  Created by Tony Xiao on 3/13/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Misc.h"

#if TARGETING_OSX

@interface CLSharedFileList : NSObject

@property (nonatomic, assign) LSSharedFileListRef lsList;
@property (nonatomic, strong) RACSignal *listChanged;

- (id)initWithListName:(CFStringRef)listName;

// Low level API
- (NSArray *)itemsSnapshot;
- (LSSharedFileListItemRef)itemRefForURL:(NSURL *)url;
- (LSSharedFileListItemRef)insertUrl:(NSURL *)url name:(NSString *)name icon:(NSImage *)icon props:(NSDictionary *)properties after:(LSSharedFileListItemRef)afterItem;

// High level API
- (void)addURL:(NSURL *)url;
- (BOOL)containsURL:(NSURL *)url;
- (void)removeURL:(NSURL *)url;

- (void)setValue:(id)value forProperty:(CFStringRef)name ofItemWithURL:(NSURL *)url;

// Login item related
+ (BOOL)isLaunchAtStartup;
+ (void)setLaunchAtStartup:(BOOL)launch;

@end

#endif