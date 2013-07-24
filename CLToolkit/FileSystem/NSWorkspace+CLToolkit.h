//
//  NSWorkspace+CLToolkit.h
//  Collections
//
//  Created by Indragie Karunaratne on 2012-08-13.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "FileSystem.h"

@interface NSWorkspace (Convenience)

- (BOOL)moveFileToTrash:(NSString *)filePath;

- (NSImage *)iconForMimeType:(NSString *)mimeType;
- (NSImage *)iconForFileExtension:(NSString *)ext;

@end
