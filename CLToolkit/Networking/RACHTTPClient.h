//
//  RACHTTPClient.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "Networking.h"

@interface RACSignal (HTTPClientAddition)

@property (nonatomic, readonly) AFHTTPRequestOperation *httpOperation;

@end

@interface RACHTTPClient : AFHTTPRequestOperationManager

// Simple Requests
- (RACSignal *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (RACSignal *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (RACSignal *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (RACSignal *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters;
- (RACSignal *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters;

// Multipart Form Data Request
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block;

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method URLString:(NSString *)URLString headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters;
- (RACSignal *)enqueueRequest:(NSURLRequest *)request;
- (RACSignal *)enqueueOperation:(AFHTTPRequestOperation *)operation;

+ (instancetype)sharedInstance;

@end

@interface AFNetworkReachabilityManager (Reactive)

// Status signal makes use of the reachabilityChangedBlock, so don't override
@property (nonatomic, readonly) RACSignal *statusSignal;

@end
