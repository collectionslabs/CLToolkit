//
//  RACDownloadOperation.h
//  Collections
//
//  Created by Tony Xiao on 10/29/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#ifdef Collections_FileSystem_h
#import "Networking.h"

@interface RACDownloadOperation : AFHTTPRequestOperation

@property (nonatomic, strong) NSURL *tempURL;
@property (nonatomic, strong) NSURL *targetFolder;
@property (nonatomic, strong) NSURL *finalURL;

- (id)initWithRequest:(NSURLRequest *)urlRequest targetFolder:(NSURL *)targetFolder;

@end
#endif