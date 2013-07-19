//
//  NSWorkspace+Convenience.m
//  Collections
//
//  Created by Indragie Karunaratne on 2012-08-13.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "NSWorkspace+Convenience.h"

@implementation NSWorkspace (Convenience)

- (BOOL)moveFileToTrash:(NSString*)filePath {
    if (!filePath)
        return NO;
    return [self performFileOperation:NSWorkspaceRecycleOperation
                               source:[filePath stringByDeletingLastPathComponent]
                          destination:@""
                                files:@[[filePath lastPathComponent]]
                                  tag:0];
}

- (NSImage *)iconForMimeType:(NSString *)mimeType {
    NSString * uti = (__bridge_transfer NSString *)
        UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mimeType, NULL);
    return [uti hasPrefix:@"dyn"] ? nil : [self iconForFileType:uti];
}

- (NSImage *)iconForFileExtension:(NSString *)ext {
    NSString * uti = (__bridge_transfer NSString *)
        UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
    return [uti hasPrefix:@"dyn"] ? nil : [self iconForFileType:uti];
}

@end
