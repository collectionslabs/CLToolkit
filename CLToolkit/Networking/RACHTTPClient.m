//
//  RACHTTPClient.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "RACHTTPClient.h"

static char kHTTPOperation;

@implementation AFHTTPRequestOperation (BugFix)

- (id)cl_responseObject {
    id responseObject = [self cl_responseObject];
    if (!responseObject) {
        NSError *error = nil;
        [self.responseSerializer validateResponse:self.response data:self.responseData error:&error];
        if (error)
            [self performSelector:@selector(setResponseSerializationError:) withObject:error];
    }
    return responseObject;
}

+ (void)load {
    [$ swizzleMethod:@selector(responseObject) with:@selector(cl_responseObject) in:self];
}

@end

@implementation RACSignal (HTTPClientAddition)

- (AFHTTPRequestOperation *)httpOperation {
    return [self associatedValueForKey:&kHTTPOperation];
}

- (void)setHttpOperation:(AFHTTPRequestOperation *)httpOperation {
    [self weaklyAssociateValue:httpOperation withKey:&kHTTPOperation];
}

@end

@implementation RACHTTPClient

- (RACSignal *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"GET" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"HEAD" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"POST" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"PUT" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"PATCH" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"DELETE" URLString:URLString headers:nil parameters:parameters];
}

- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block {
    NSString *absoluteURL = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer
                                    multipartFormRequestWithMethod:@"POST"
                                    URLString:absoluteURL
                                    parameters:parameters
                                    constructingBodyWithBlock:block];
    return [self enqueueRequest:request];
}

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method URLString:(NSString *)URLString headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters {
    NSString *absoluteURL = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                                   URLString:absoluteURL
                                                                  parameters:parameters];
    [request setHTTPHeaders:headers];
    return [self enqueueRequest:request];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
    return [self enqueueOperation:operation];
}

- (RACSignal *)enqueueOperation:(AFHTTPRequestOperation *)operation {
    RACSubject *subject = [RACReplaySubject subject];
    subject.name = $str(@"HTTP %@ %@", operation.request.HTTPMethod, operation.request.URL);
    [subject setHttpOperation:operation];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [operation.response setData:operation.responseData];
		[subject sendNextAndComplete:operation.response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] setData:operation.responseData];
		[subject sendError:error];
    }];
    [self.operationQueue addOperation:operation];
	return subject;
}

#pragma mark Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static RACHTTPClient *__sharedInstance = nil;
    dispatch_once(&onceQueue, ^{
        __sharedInstance = [[self alloc] initWithBaseURL:nil];
    });
    return __sharedInstance;
}

@end

static char kStatusSignal;

@implementation AFNetworkReachabilityManager (Reactive)

- (RACSignal *)statusSignal {
    @synchronized(self) {
        RACSignal *signal = [self associatedValueForKey:&kStatusSignal];
        if (!signal) {
            RACSubject *subject = [RACReplaySubject replaySubjectWithCapacity:1];
            [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                [subject sendNext:@(status)];
            }];
            signal = [subject distinctUntilChanged];
            [self associateValue:signal withKey:&kStatusSignal];
        }
        return signal;
    }
}

@end