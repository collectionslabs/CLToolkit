//
//  CLS3Client.m
//  Collections
//
//  Created by Tony Xiao on 4/22/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <AWSRuntime/AmazonStaticCredentialsProvider.h>
#import "NSString+Concise.h"
#import "CLS3Client.h"

@implementation CLS3Client

- (RACSignal *)credentialsForKey:(NSString *)key {
    return [RACSignal return:[[AmazonCredentials alloc] initWithAccessKey:@"access_key"
                                                            withSecretKey:@"secret_key"
                                                        withSecurityToken:@"session_token"]];
}

- (S3Response *)invoke:(S3Request *)request {
    S3Response *response = nil;
    if (request.delegate) {
        // Async
        [[self credentialsForKey:request.key] subscribeNext:^(AmazonCredentials *credentials) {
            @synchronized(self) {
                AmazonStaticCredentialsProvider *oldProvider = self.provider;
                self.provider = [[AmazonStaticCredentialsProvider alloc] initWithCredentials:credentials];
                [super invoke:request];
                self.provider = oldProvider;
            }
        } error:^(NSError *error) {
            NSLog(@"Unable to obtain credentials %@", error);
        }];
    } else {
        // Sync. Really should never ever be used
        @synchronized(self) {
            AmazonStaticCredentialsProvider *oldProvider = self.provider;
            AmazonCredentials *credentials = [[self credentialsForKey:request.key] first];
            self.provider = [[AmazonStaticCredentialsProvider alloc] initWithCredentials:credentials];
            response = [super invoke:request];
            self.provider = oldProvider;
        }
    }
    return response;
}

@end
