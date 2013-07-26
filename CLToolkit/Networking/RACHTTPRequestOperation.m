//
//  RACHTTPRequestOperation.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "RACHTTPRequestOperation.h"

@implementation RACHTTPRequestOperation {
    RACSubject *_onFinish;
}

- (id)responseObject {
    return self.response;
}

- (RACSignal *)onFinish {
    return _onFinish ?: (_onFinish = [RACReplaySubject subject]);
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success
                              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    @weakify(self);
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        [self->_onFinish sendNextAndComplete:self.response];
        if (success)
            success(operation, self.response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        [self->_onFinish sendError:error];
        if (failure)
            failure(operation, error);
    }];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    NSAssert(urlRequest.URL, @"URL cannot be nil for download request");
    return (self = [super initWithRequest:urlRequest]);
}

#pragma mark NSURLConnection Delegate Override

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSAssert([self.response respondsToSelector:@selector(setData:)], @"Cannot use RACHTTPRequestOperation without required category");
    [self.response setData:[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
    [super connectionDidFinishLoading:connection];
}

#pragma mark Class Methods

+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest {
    return YES;
}

@end


#define ACCEPTABLE_JSON_EXTENSIONS              $set(@"json")
#define ACCEPTABLE_JSON_CONTENT_TYPES           $set(@"application/json", @"text/json", @"text/javascript")

#define ACCEPTABLE_XML_EXTENSIONS               $set(@"xml")
#define ACCEPTABLE_XML_CONTENT_TYPES            $set(@"application/xml", @"text/xml")

#define ACCEPTABLE_PROPERTY_LIST_EXTENSIONS     $set(@"plist")
#define ACCEPTABLE_PROPERTY_LIST_CONTENT_TYPES  $set(@"application/x-plist")

#define ACCEPTABLE_IMAGE_EXTENSIONS             $set(@"tif", @"tiff", @"jpg", @"jpeg", @"gif", @"png", @"ico", @"bmp", @"cur")
#define ACCEPTABLE_IMAGE_CONTENT_TYPES          $set(@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon",\
@"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap")

@implementation NSHTTPURLResponse (ResponseData)

- (void)setData:(NSData *)data { [self associateValue:data withKey:"data"]; }
- (NSData *)data { return [self associatedValueForKey:"data"]; }

- (void)setError:(NSError *)error { [self associateValue:error withKey:"error"]; }
- (NSError *)error { return [self associatedValueForKey:"error"]; }

- (NSString *)text {
    if (![self associatedValueForKey:"text"]) {
        NSStringEncoding textEncoding = NSUTF8StringEncoding;
        if (self.textEncodingName) {
            textEncoding = CFStringConvertEncodingToNSStringEncoding(
                            CFStringConvertIANACharSetNameToEncoding(
                              (__bridge CFStringRef)self.textEncodingName));
        }
        [self associateValue:[[NSString alloc] initWithData:self.data encoding:textEncoding] withKey:"text"];
    }
    return [self associatedValueForKey:"text"];
}

- (id)json {
    if (![self associatedValueForKey:"json"] && [self.data length]) {
        NSError *error = nil;
        [self associateValue:[NSJSONSerialization JSONObjectWithData:self.data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error]
                     withKey:"json"];
        self.error = error;
    }
    return [self associatedValueForKey:"json"];
}

- (NSXMLParser *)xml {
    if (![self associatedValueForKey:"xml"] && [self.data length]) {
        [self associateValue:[[NSXMLParser alloc] initWithData:self.data] withKey:"xml"];
    }
    return [self associatedValueForKey:"xml"];
}

- (id)propertyList {
    if (![self associatedValueForKey:"propertyList"] && [self.data length]) {
        NSError *error = nil;
        [self associateValue:[NSPropertyListSerialization propertyListWithData:self.data
                                                                       options:NSPropertyListMutableContainersAndLeaves
                                                                        format:NULL
                                                                         error:&error]
                     withKey:"propertyList"];
        self.error = error;
    }
    return [self associatedValueForKey:"propertyList"];
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (UIImage *)image {
    if (![self associatedValueForKey:"image"] && [self.data length]) {
        [self associateValue:[UIImage imageWithData:self.data] withKey:"image"];
    }
    return [self associatedValueForKey:"image"];
}
#else
- (NSImage *)image {
    if (![self associatedValueForKey:"image"] && [self.data length]) {
        NSBitmapImageRep *bitimage = [[NSBitmapImageRep alloc] initWithData:self.data];
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([bitimage pixelsWide], [bitimage pixelsHigh])];
        [image addRepresentation:bitimage];
        [self associateValue:image withKey:"image"];
    }
    return [self associatedValueForKey:"image"];
}
#endif

@end
