//
//  CLS3TransferManager.h
//  Collections
//
//  Created by Tony Xiao on 4/23/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <AWSRuntime/S3/S3TransferManager.h>

@class CLFile;
@interface AmazonServiceRequest (Reactive)

- (RACSignal *)signal;
- (RACSignal *)uploadSignal;
- (RACSignal *)downloadSignal;

@end

@interface CLS3TransferManager : S3TransferManager <AmazonServiceRequestDelegate>

- (S3PutObjectRequest *)uploadFileAtURL:(NSURL *)url toBucket:(NSString *)bucket key:(NSString *)key;

+ (instancetype)sharedManager;

@end

@protocol CLOperation <NSObject>

- (NSImage *)image;
- (NSString *)status; // Human readable status
- (CGFloat)percentComplete; // 0 - 100. Should be observable

@end

@protocol CLFileTransferOperation <CLOperation>

- (NSString *)fileID; // Remote and globally unique file id
- (NSString *)fileTransferID;
- (CLFile *)localFile;
- (NSUInteger)totalBytes;
- (NSUInteger)completedBytes;

@end
