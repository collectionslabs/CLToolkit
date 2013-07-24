//
//  CLFile.h
//  FileSystem
//
//  Created by Tony Xiao on 10/19/12.
//  Copyright (c) 2012 Collections. All rights reserved.
//

#import "FileSystem.h"

@interface CLFile : NSObject;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) NSImage *image;
@property (nonatomic, readonly) BOOL exists;
@property (nonatomic, readonly) BOOL isDirectory;
@property (nonatomic, readonly) NSDate *dateCreated;
@property (nonatomic, readonly) NSDate *dateModified;
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) NSString *kind;
@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly) id<NSFastEnumeration> children;

- (id)initWithURL:(NSURL *)url;

- (void)refresh;

- (CLFile *)renameTo:(NSString *)filename;
- (CLFile *)moveToURL:(NSURL *)url;
- (CLFile *)copyToURL:(NSURL *)url;
- (CLFile *)moveToFolder:(NSURL *)folderURL;
- (CLFile *)copyToFolder:(NSURL *)folderURL;

@end
