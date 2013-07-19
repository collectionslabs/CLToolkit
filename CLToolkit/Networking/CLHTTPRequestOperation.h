//
//  CLHTTPRequestOperation.h
//  Collections
//
//  Created by Tony Xiao on 10/28/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>
#import "RACHTTPRequestOperation.h"

@interface CLHTTPRequestOperation : AFHTTPRequestOperation

- (id)responseObject;
- (void)setSimpleCompletionBlock:(void (^)(id responseObject, NSError *error))block;
- (void)setCompletionBlockWithSuccess:(void (^)(CLHTTPRequestOperation *op,id responseObject))success
                              failure:(void (^)(CLHTTPRequestOperation *op, NSError *))failure;

@end
