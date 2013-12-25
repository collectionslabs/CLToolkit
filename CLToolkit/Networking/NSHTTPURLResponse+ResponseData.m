//
//  NSHTTPURLResponse+ResponseData.m
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "NSHTTPURLResponse+ResponseData.h"

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

- (void)setData:(NSData *)data { [self bk_associateValue:data withKey:"data"]; }
- (NSData *)data { return [self bk_associatedValueForKey:"data"]; }

- (void)setError:(NSError *)error { [self bk_associateValue:error withKey:"error"]; }
- (NSError *)error { return [self bk_associatedValueForKey:"error"]; }

- (NSString *)text {
    if (![self bk_associatedValueForKey:"text"]) {
        NSStringEncoding textEncoding = NSUTF8StringEncoding;
        if (self.textEncodingName) {
            textEncoding = CFStringConvertEncodingToNSStringEncoding(
                            CFStringConvertIANACharSetNameToEncoding(
                              (__bridge CFStringRef)self.textEncodingName));
        }
        [self bk_associateValue:[[NSString alloc] initWithData:self.data encoding:textEncoding] withKey:"text"];
    }
    return [self bk_associatedValueForKey:"text"];
}

- (id)json {
    if (![self bk_associatedValueForKey:"json"] && [self.data length]) {
        NSError *error = nil;
        [self bk_associateValue:[NSJSONSerialization JSONObjectWithData:self.data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error]
                     withKey:"json"];
        self.error = error;
    }
    return [self bk_associatedValueForKey:"json"];
}

- (NSXMLParser *)xml {
    if (![self bk_associatedValueForKey:"xml"] && [self.data length]) {
        [self bk_associateValue:[[NSXMLParser alloc] initWithData:self.data] withKey:"xml"];
    }
    return [self bk_associatedValueForKey:"xml"];
}

- (id)propertyList {
    if (![self bk_associatedValueForKey:"propertyList"] && [self.data length]) {
        NSError *error = nil;
        [self bk_associateValue:[NSPropertyListSerialization propertyListWithData:self.data
                                                                       options:NSPropertyListMutableContainersAndLeaves
                                                                        format:NULL
                                                                         error:&error]
                     withKey:"propertyList"];
        self.error = error;
    }
    return [self bk_associatedValueForKey:"propertyList"];
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (UIImage *)image {
    if (![self bk_associatedValueForKey:"image"] && [self.data length]) {
        [self bk_associateValue:[UIImage imageWithData:self.data] withKey:"image"];
    }
    return [self bk_associatedValueForKey:"image"];
}
#else
- (NSImage *)image {
    if (![self bk_associatedValueForKey:"image"] && [self.data length]) {
        NSBitmapImageRep *bitimage = [[NSBitmapImageRep alloc] initWithData:self.data];
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([bitimage pixelsWide], [bitimage pixelsHigh])];
        [image addRepresentation:bitimage];
        [self bk_associateValue:image withKey:"image"];
    }
    return [self bk_associatedValueForKey:"image"];
}
#endif

@end
