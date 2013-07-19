//
//  CLS3TransferManager.m
//  Collections
//
//  Created by Tony Xiao on 4/23/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "NSObject+CLExtensions.h"
#import "CLS3Client.h"
#import "CLS3TransferManager.h"

static const char kSignal;
static const char kUploadSignal;
static const char kDownloadSignal;

@implementation AmazonServiceRequest (Reactive)

- (RACSignal *)signal {
    return [self associatedValueForKey:&kSignal default:[RACReplaySubject subject]];
}

- (RACSignal *)uploadSignal {
    return [self associatedValueForKey:&kUploadSignal default:[RACReplaySubject subject]];
}

- (RACSignal *)downloadSignal {
    return [self associatedValueForKey:&kDownloadSignal default:[RACReplaySubject subject]];
}

@end

@implementation CLS3TransferManager

- (id)init {
    if (self = [super init]) {
        self.s3 = [[CLS3Client alloc] init];
        self.delegate = self;
    }
    return self;
}

- (S3PutObjectRequest *)uploadFileAtURL:(NSURL *)url toBucket:(NSString *)bucket key:(NSString *)key {
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] init];
    putObjectRequest.filename = url.path;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;
    [self upload:putObjectRequest];
    return putObjectRequest;
}

#pragma mark AmazonServiceRequest Delegate

- (void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response {
    [(RACSubject *)request.signal sendNext:response];
}

- (void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data {
    [(RACSubject *)request.downloadSignal sendNext:data];
}

- (void)request:(AmazonServiceRequest *)request didSendData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    RACTuple *tuple = RACTuplePack(@(bytesWritten), @(totalBytesWritten), @(totalBytesExpectedToWrite));
    [(RACSubject *)request.uploadSignal sendNext:tuple];
}

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
    [(RACSubject *)request.signal sendCompleted];
    [(RACSubject *)request.uploadSignal sendCompleted];
    [(RACSubject *)request.downloadSignal sendCompleted];
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
    [(RACSubject *)request.signal sendError:error];
    [(RACSubject *)request.uploadSignal sendError:error];
    [(RACSubject *)request.downloadSignal sendError:error];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception {
    [self request:request didFailWithError:ErrorFromException(exception)];
}
#pragma clang diagnostic pop

#pragma mark Class Methods

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static CLS3TransferManager *__manager = nil;
    dispatch_once(&onceToken, ^{
        __manager = [[self alloc] init];
    });
    return __manager;
}

@end
