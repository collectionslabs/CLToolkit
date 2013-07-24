//
//  RACHTTPRequestOperation.h
//
//  Created by Tony Xiao on 07/09/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "Networking.h"

@interface RACHTTPRequestOperation : AFHTTPRequestOperation

@property (nonatomic, readonly) RACSignal *onFinish;

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
