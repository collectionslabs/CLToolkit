//
//  CLS3Client.h
//  Collections
//
//  Created by Tony Xiao on 4/22/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "AWS.h"
#import <AWSRuntime/S3/AmazonS3Client.h>

@interface CLS3Client : AmazonS3Client

- (RACSignal *)credentialsForKey:(NSString *)key;

@end
