//
//  NSFileManager+CLExtensions.h
//  Collections
//
//  Created by Tony Xiao on 8/9/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (CLExtensions)

- (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL;
- (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL;

- (NSURL *)moveItemAtURL:(NSURL *)srcURL toTargetURL:(NSURL *)targetURL error:(NSError *__autoreleasing *)error;
- (NSURL *)createTempFolderInFolder:(NSURL *)folder;
- (NSURL *)createTempFileInFolder:(NSURL *)folder;
- (NSURL *)ensureFolder:(NSURL *)folder;
- (NSURL *)readableURLFromURL:(NSURL *)fileURL suggestFilename:(NSString *)filename;

@end
