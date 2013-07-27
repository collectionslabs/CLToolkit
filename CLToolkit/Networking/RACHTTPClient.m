//
//  RACHTTPClient.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "RACHTTPClient.h"

#if DEBUG

static const char kCLHTTPParams;

static int CurrentTag(void) {
    static int currentTag = 1;
    return currentTag++;
}

static void LogHTTPRequest(int tag, NSURLRequest *request) {
    NSString *method = [request HTTPMethod];
    NSString *path = request.URL.path;
    path = [path sliceTill:[path rangeOfString:@"?"].location];
    id params = [request associatedValueForKey:&kCLHTTPParams] ?: $jsonLoadsData([request HTTPBody]);
    NSString *desc = [params description] ?: @"";
    if ([[method uppercaseString] isEqualToString:@"GET"])
        desc = [[desc replace:@"\n" with:@" "] replace:@"  " with:@""];
    LogDebug(@"http", @"R%-2d ->   %@ %@ %@", tag, method, path, desc);
    LoggerFlush(NULL, NO);
}
static void LogHTTPResponse(int tag, NSHTTPURLResponse *response) {
    NSDictionary *headers = response.allHeaderFields;
    NSString *path = response.URL.path;
    id body = [response json];
    NSString *tagStr = [$str(@"<-  R%d     ", tag) sliceTill:8];
    LogDebug(@"http", @"%@ %ld %@\n Body: %@\n Headers: %@", tagStr, (long)response.statusCode, path, body, headers);
    LoggerFlush(NULL, NO);
}
static void LogHTTPError(int tag, NSError *error) {
    NSString *tagStr = [$str(@"<-  R%d     ", tag) sliceTill:8];
    LogError(@"http", @"%@ Error %@", tagStr, error);
    LoggerFlush(NULL, NO);
}

#else

static void LogHTTPRequest(int tag, NSURLRequest *request) {}
static void LogHTTPResponse(int tag, NSHTTPURLResponse *response) {}
static void LogHTTPError(int tag, NSError *error) {}
static int CurrentTag(void) { return 0; }

#endif

@interface AFStreamingMultipartFormData : NSObject <AFMultipartFormData>
@end

@implementation AFStreamingMultipartFormData(Filename)

- (BOOL)CL_appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name error:(NSError *__autoreleasing *)error {
    if ([self CL_appendPartWithFileURL:fileURL name:name error:error]) {
        NSMutableDictionary *bodyPartHeaders = [[[self valueForKeyPath:@"bodyStream.HTTPBodyParts"] lastObject] valueForKeyPath:@"headers"];
        bodyPartHeaders[@"Content-Disposition"] = $str(@"form-data; name=\"%@\"; filename=\"%@\"", name, fileURL.lastPathComponent);
        return YES;
    }
    return NO;
}

+ (void)load {
    [$ swizzleMethod:@selector(CL_appendPartWithFileURL:name:error:)
                with:@selector(appendPartWithFileURL:name:error:)
                  in:[self class]];
}

@end

@implementation RACHTTPClient

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[RACHTTPRequestOperation class]];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *req = [super requestWithMethod:method path:path parameters:parameters];
    [req setHTTPShouldHandleCookies:self.useCookie];
#if DEBUG
    if (parameters.count)
        [req associateValue:parameters withKey:&kCLHTTPParams];
#endif
    if (!self.useCookie)
        [req removeHTTPHeaderForKey:@"Cookie"];
    return req;
}

#pragma mark -

- (RACSignal *)getPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"GET" path:path headers:nil parameters:parameters];
}

- (RACSignal *)postPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"POST" path:path headers:nil parameters:parameters];
}

- (RACSignal *)putPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"PUT" path:path headers:nil parameters:parameters];
}

- (RACSignal *)patchPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"PATCH" path:path headers:nil parameters:parameters];
}

- (RACSignal *)deletePath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self enqueueRequestWithMethod:@"DELETE" path:path headers:nil parameters:parameters];
}

- (RACSignal *)enqueueRequestWithMethod:(NSString *)method path:(NSString *)path headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    [request setHTTPHeaders:headers];
    request.timeoutInterval = 30; // 30 second timeout (heroku limit anyways)
    return [self enqueueRequest:request];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
    return [self enqueueOperation:operation];
}

- (RACSignal *)enqueueOperation:(AFHTTPRequestOperation *)operation {
    int tag = CurrentTag();
    RACSubject *subject = [RACReplaySubject subject];
    subject.name = $str(@"HTTP %@ %@", operation.request.HTTPMethod, operation.request.URL);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        LogHTTPResponse(tag, operation.response);
		[subject sendNext:responseObject];
		[subject sendCompleted];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LogHTTPError(tag, error);
		[subject sendError:error];
    }];
    [self enqueueHTTPRequestOperation:operation];
    LogHTTPRequest(tag, operation.request);
	return subject;
}

#pragma mark Class Methods

+ (instancetype)clientWithBaseURL:(NSURL *)url {
    return (RACHTTPClient *)[super clientWithBaseURL:url];
}

+ (instancetype)sharedClient {
    static dispatch_once_t onceQueue;
    static RACHTTPClient *__sharedClient = nil;
    
    dispatch_once(&onceQueue, ^{
        __sharedClient = [self clientWithBaseURL:$url(@"http://localhost/")];
    });
    return __sharedClient;
}

@end
