//
//  RACHTTPClient.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "Networking.h"

@interface RACHTTPClient : AFHTTPClient

@property (nonatomic, assign) BOOL useCookie;

- (RACSignal *)getPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)postPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)putPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)patchPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)deletePath:(NSString *)path parameters:(NSDictionary *)parameters;
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters;
- (RACSignal *)enqueueRequest:(NSURLRequest *)request;
- (RACSignal *)enqueueOperation:(AFHTTPRequestOperation *)operation;

+ (instancetype)clientWithBaseURL:(NSURL *)url;
+ (instancetype)sharedInstance;

@end
