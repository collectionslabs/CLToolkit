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

@implementation CLUpdateHelper {
    NSTimer *_watchdogTimer;
}

- (id)initWithAppPath:(NSString *)appPath updatePath:(NSString *)updatePath parentProcessId:(pid_t)ppid shouldRelaunch:(BOOL)relaunch {
    if (self = [super init]) {
        _appPath = appPath;
        _updatePath = updatePath;
        _ppid = ppid;
        _relaunch = relaunch;
    }
    return self;
}

- (void)installUpdate {
    NSLog(@"Replacing old app at %@ with update at %@", self.appPath, self.updatePath);
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] replaceItemAtURL:[NSURL fileURLWithPath:self.appPath]
                                                      withItemAtURL:[NSURL fileURLWithPath:self.updatePath]
                                                     backupItemName:nil options:0 resultingItemURL:NULL error:&error];
    if (!success || error) {
        [[NSAlert alertWithError:error] runModal];
        exit(EXIT_FAILURE);
    } else {
        if (self.cleanPath) {
            NSLog(@"Cleaning path %@", self.cleanPath);
            if (![[NSFileManager defaultManager] removeItemAtPath:self.cleanPath error:&error])
                NSLog(@"Unable to clean path. Error: %@, going to open app anyway", error);
        }
        if (self.relaunch) {
            NSLog(@"Opening app at path %@", self.appPath);
            [[NSWorkspace sharedWorkspace] openFile:self.appPath];
        }
        exit(EXIT_SUCCESS);
    }
}

- (void)watchdog:(NSTimer *)aTimer {
    ProcessSerialNumber psn;
	if (GetProcessForPID(self.ppid, &psn) == procNotFound) {
        [aTimer invalidate];
        _watchdogTimer = nil;
		[self installUpdate];
    }
}

- (void)start {
    NSLog(@"UpdateHelper started appPath %@ updatePath %@ cleanPath %@ ppid %d relaunch %d",
          self.appPath, self.updatePath, self.cleanPath, self.ppid, self.relaunch);
    if (getppid() == 1) {
        // ppid is launchd (1) => parent terminated already
        [self installUpdate];
    } else {
        _watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(watchdog:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

@end


int main(int argc, char *argv[]) {
	if(argc != 6) {
        NSLog(@"Usage: UpdateHelper appPath updatePath cleanPath ppid relaunch");
		return EXIT_FAILURE;
    }
    
    @autoreleasepool {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        
        CLUpdateHelper *helper = [[CLUpdateHelper alloc] init];
        
        helper.appPath    = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        helper.updatePath = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        helper.cleanPath  = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
        helper.ppid       = atoi(argv[4]);
        helper.relaunch   = atoi(argv[5]);
        
        [helper start];
        
        [[NSApplication sharedApplication] run];
    }
    return EXIT_SUCCESS;
}
