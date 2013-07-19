//
//  CLHTTPRequestOperation.m
//  Collections
//
//  Created by Tony Xiao on 10/28/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLHTTPRequestOperation.h"

@implementation CLHTTPRequestOperation

- (id)responseObject {
    return self.response;
}

- (void)setSimpleCompletionBlock:(void (^)(id, NSError *))block {
    [self setCompletionBlockWithSuccess:^(CLHTTPRequestOperation *op, id responseObject) {
        block(responseObject, nil);
    } failure:^(CLHTTPRequestOperation *op, NSError *error) {
        block(nil, error);
    }];
}

- (void)setCompletionBlockWithSuccess:(void (^)(CLHTTPRequestOperation *, id))success
                              failure:(void (^)(CLHTTPRequestOperation *, NSError *))failure {
    __block CLHTTPRequestOperation *this = self;
    self.completionBlock  = ^{
        if ([this isCancelled])
            return;
        if (this.error) {
            if (failure) {
                dispatch_async(this.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(this, this.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(this.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                    success(this, this.responseObject);
                });
            }
        }
    };
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    NSAssert(urlRequest.URL, @"URL cannot be nil for download request");
    return (self = [super initWithRequest:urlRequest]);
}

#pragma mark NSURLConnection Delegate Override

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSAssert([self.response respondsToSelector:@selector(setData:)], @"Cannot use CLHTTPRequestOperation without required category");
    [self.response setData:[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
    [super connectionDidFinishLoading:connection];
}

#pragma mark Class Methods

+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest {
    return YES;
}

@end
