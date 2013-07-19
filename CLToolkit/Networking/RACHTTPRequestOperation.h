//
//  RACHTTPRequestOperation.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface RACHTTPRequestOperation : AFHTTPRequestOperation

- (id)responseObject;
- (void)setSimpleCompletionBlock:(void (^)(id responseObject, NSError *error))block;
- (void)setCompletionBlockWithSuccess:(void (^)(RACHTTPRequestOperation *op,id responseObject))success
                              failure:(void (^)(RACHTTPRequestOperation *op, NSError *))failure;

@end

@interface NSHTTPURLResponse (ResponseData)

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;
@property (readonly) NSString *text;
@property (readonly) id json;
@property (readonly) id propertyList;
@property (readonly) NSXMLParser *xml;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property (readonly) UIImage *image;
#else
@property (readonly) NSImage *image;
#endif

@end
