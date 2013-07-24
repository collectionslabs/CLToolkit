//
//  RACDownloadOperation.m
//  Collections
//
//  Created by Tony Xiao on 10/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "RACDownloadOperation.h"
#import "NSFileManager+CLExtensions.h"

@implementation RACDownloadOperation {
    __block NSError *_fileError;
}


- (id)responseObject { return self.finalURL; }

- (NSURL *)tempURL {
    return _tempURL ?: (_tempURL = [[NSFileManager defaultManager] createTempFileInFolder:AppTempDir()]);
}

- (BOOL)deleteTempFile {
    if (![self.tempURL checkResourceIsReachableAndReturnError:NULL])
        return YES;
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:self.tempURL error:&error];
    _fileError = error;
    return success;
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success
                              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    @weakify(self);
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSURL *url = [self.targetFolder URLByAppendingPathComponent:self.response.suggestedFilename];
        NSError *error;
        self.finalURL = [FM moveItemAtURL:self.tempURL toTargetURL:url error:&error];
        self->_fileError = error;
        if (self.error && failure) {
            failure(operation, self.error);
        } else if (success) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        [self deleteTempFile];
        if (failure)
            failure(operation, error);
    }];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest targetFolder:(NSURL *)targetFolder {
    if (self = [super initWithRequest:urlRequest]) {
        self.targetFolder = targetFolder;
        self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempURL.path append:NO];
    }
    return self;
}

@end
