//
//  CLFile.m
//  FileSystem
//
//  Created by Tony Xiao on 10/19/12.
//  Copyright (c) 2012 Collections. All rights reserved.
//

#import <ReactiveCocoa/NSEnumerator+RACSequenceAdditions.h>
#import <AWSRuntime/AmazonMD5Util.h>
#import "NSFileManager+CLExtensions.h"
#import "CLFile.h"

@interface CLFile() {
    NSDictionary *_attributes;
}

@end

@implementation CLFile

- (id)initWithURL:(NSURL *)url {
    NSParameterAssert(url.isFileURL);
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (NSDictionary *)attributes {
    return _attributes ?: (_attributes = [FM attributesOfItemAtPath:self.url.path error:NULL]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CLFile %@>", self.url.path];
}

#pragma mark Accessors

- (NSString *)filename { return [self.url lastPathComponent]; }
- (BOOL)exists { return [self.url checkResourceIsReachableAndReturnError:NULL]; }
- (BOOL)isDirectory { return [[self attributes] fileType] == NSFileTypeDirectory; }
- (NSDate *)dateCreated { return self.attributes[NSFileCreationDate]; }
- (NSDate *)dateModified { return self.attributes[NSFileModificationDate]; }
- (NSUInteger)size { return [self.attributes[NSFileSize] unsignedIntegerValue]; }
- (CLImage *)image { return [CLImage imageWithPreviewsOfFile:self.url]; }
- (NSString *)kind {
    NSString *uti;
    [self.url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    return [[NSWorkspace sharedWorkspace] localizedDescriptionForType:uti];
}

- (NSString *)md5 {
    return self.exists ? [AmazonMD5Util base64md5FromStream:[NSInputStream inputStreamWithURL:self.url]] : nil;
}

- (id<NSFastEnumeration>)children {
    return [[[FM enumeratorAtURL:self.url includingPropertiesForKeys:@[]
                         options:(NSDirectoryEnumerationSkipsHiddenFiles |
                                  NSDirectoryEnumerationSkipsSubdirectoryDescendants |
                                  NSDirectoryEnumerationSkipsPackageDescendants)
                    errorHandler:nil] rac_sequence] map:^id(NSURL *url) {
        return [[CLFile alloc] initWithURL:url];
    }];
}

#pragma mark File Operations

- (void)refresh {
    _attributes = nil;
}

- (CLFile *)renameTo:(NSString *)filename {
    return [self moveToURL:[self.url.URLByDeletingLastPathComponent URLByAppendingPathComponent:filename]];
}

- (CLFile *)moveToURL:(NSURL *)url {
    if ([self.url isEqual:url])
        return self;
    if (self.exists && [FM ensureFolder:url.URLByDeletingLastPathComponent])
        if ([FM moveItemAtURL:self.url toURL:url])
            return [[CLFile alloc] initWithURL:url];
    return nil;
}

- (CLFile *)copyToURL:(NSURL *)url {
    if ([self.url isEqual:url])
        return self;
    if (self.exists && [FM ensureFolder:url.URLByDeletingLastPathComponent])
        if ([FM copyItemAtURL:self.url toURL:url])
            return [[CLFile alloc] initWithURL:url];
    return nil;
}

- (CLFile *)moveToFolder:(NSURL *)folderURL {
    return [self moveToURL:[folderURL URLByAppendingPathComponent:self.filename]];
}

- (CLFile *)copyToFolder:(NSURL *)folderURL {
    return [self copyToURL:[folderURL URLByAppendingPathComponent:self.filename]];
}

@end
