//
//  CLDownloadRequestOperation.m
//  Collections
//
//  Created by Tony Xiao on 10/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLDownloadOperation.h"
#import "NSFileManager+CLExtensions.h"

@implementation CLDownloadOperation {
    __block NSError *_fileError;
}


- (id)responseObject { return self.finalURL; }
- (NSError *)error { return _fileError ?: [super error]; }

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

- (void)setCompletionBlockWithSuccess:(void (^)(CLHTTPRequestOperation *, id))success
                              failure:(void (^)(CLHTTPRequestOperation *, NSError *))failure {
    __block CLDownloadOperation * this = self;
    self.completionBlock = ^{

        if (this.isCancelled) {
            [this deleteTempFile];
        } else {
            if (!this.error) {
                NSURL *url = [this.targetFolder URLByAppendingPathComponent:this.response.suggestedFilename];
                NSError *error;
                this.finalURL = [FM moveItemAtURL:this.tempURL toTargetURL:url error:&error];
                this->_fileError = error;
            }
            if (this.error) {
                [this deleteTempFile];
                dispatch_async(this.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    LogTrace(@"resource", @"Failed downloading %@ response: %@", this.request, this.response);
                    failure(this, this.error);
                });
            } else {
                dispatch_async(this.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                    LogTrace(@"resource", @"succeeded downloading %@ response %@, to %@", this.request.URL, this.response, this.finalURL);
                    success(this, this.responseObject);
                });
            }
        }
    };
}

- (id)initWithRequest:(NSURLRequest *)urlRequest targetFolder:(NSURL *)targetFolder {
    if (self = [super initWithRequest:urlRequest]) {
        self.targetFolder = targetFolder;
        self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempURL.path append:NO];
    }
    return self;
}

@end
