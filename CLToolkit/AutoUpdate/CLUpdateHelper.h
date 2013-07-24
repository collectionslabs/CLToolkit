//
//  main.m
//  UpdateHelper
//
//  Created by Tony Xiao on 11/21/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CLUpdateHelper : NSObject

@property (nonatomic, strong) NSString *appPath;
@property (nonatomic, strong) NSString *updatePath;
@property (nonatomic, strong) NSString *cleanPath;
@property (nonatomic, assign) pid_t ppid;
@property (nonatomic, assign) BOOL relaunch;

@end
