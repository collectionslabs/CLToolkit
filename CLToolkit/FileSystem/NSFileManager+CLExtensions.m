//
//  NSFileManager+CLExtensions.m
//  Collections
//
//  Created by Tony Xiao on 8/9/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "NSString+Concise.h"
#import "NSFileManager+CLExtensions.h"

@implementation NSFileManager (CLExtensions)

- (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    NSError *error = nil;
    if ([self moveItemAtURL:srcURL toURL:dstURL error:&error])
        return YES;
    NSLog(@"Error moving file %@", error);
    return NO;
}

- (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    NSError *error = nil;
    if ([self copyItemAtURL:srcURL toURL:dstURL error:&error])
        return YES;
    NSLog(@"Error copying file %@", error);
    return NO;
}

- (NSURL *)moveItemAtURL:(NSURL *)srcURL toTargetURL:(NSURL *)targetURL error:(NSError *__autoreleasing *)error {
    NSURL *destDirectory = [targetURL URLByDeletingLastPathComponent];
    NSString *baseFilename = [[targetURL lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [targetURL pathExtension];
    int suffix = 1;

    NSURL *destURL = targetURL;
    while (![self moveItemAtURL:srcURL toURL:destURL error:error]) {
        // We only catch file exists error
        if ((*error).code != NSFileWriteFileExistsError)
            break;
        
        destURL = [destDirectory URLByAppendingPathComponent:$str(@"%@-%d", baseFilename, suffix++)];
        if (extension)
            destURL = [destURL URLByAppendingPathExtension:extension];
        *error = nil;
    }
    return *error ? nil : destURL;
}

- (NSURL *)createTempFolderInFolder:(NSURL *)folder {
    const char *template = [[folder.path stringByAppendingPathComponent:@"tempFolder.XXXXXX"] fileSystemRepresentation];
    char *tempCPath = (char *)malloc(strlen(template) + 1);
    strcpy(tempCPath, template);

    char *result = mkdtemp(tempCPath);
    if (!result) {
        free(tempCPath);
        return nil;
    }
    
    NSURL *tempURL = [NSURL fileURLWithPath:[self stringWithFileSystemRepresentation:tempCPath length:strlen(tempCPath)]];
    
    free(tempCPath);
    
    return tempURL;
}

- (NSURL *)createTempFileInFolder:(NSURL *)folder {
    const char *template = [[folder.path stringByAppendingPathComponent:@"temp.XXXXXX"] fileSystemRepresentation];
    char *tempCPath = (char *)malloc(strlen(template) + 1);
    strcpy(tempCPath, template);

    int fileDescriptor = mkstemp(tempCPath);
    if (fileDescriptor == -1) {
        free(tempCPath);
        return nil;
    }
    
    NSURL *tempURL = [NSURL fileURLWithPath:[self stringWithFileSystemRepresentation:tempCPath length:strlen(tempCPath)]];
    
    free(tempCPath);
    close(fileDescriptor);
    
    return tempURL;
}

- (NSURL *)ensureFolder:(NSURL *)folder {
    if (![self createDirectoryAtURL:folder withIntermediateDirectories:YES attributes:nil error:NULL])
        return nil;
    return folder;
}

- (NSURL *)readableURLFromURL:(NSURL *)fileURL suggestFilename:(NSString *)filename {
    if (fileURL && ![filename isEqualToString:fileURL.lastPathComponent]) {
        filename = filename.safeFilename;
        if (![filename.pathExtension isEqualToString:fileURL.pathExtension])
            filename = [filename stringByAppendingPathExtension:fileURL.pathExtension];
        
        if (filename) {
            NSURL *readableFileURL = [[FM createTempFolderInFolder:AppTempDir()] URLByAppendingPathComponent:filename];
            if ([FM copyItemAtURL:fileURL toURL:readableFileURL error:NULL])
                return readableFileURL;
        }
    }
    return fileURL;

}

@end
