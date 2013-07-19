//
//  CLUpdater.m
//  Collections
//
//  Created by Tony Xiao on 11/21/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <ReactiveCocoa/NSTask+RACSupport.h>
#import "NSFileManager+CLExtensions.h"
#import "CLDownloadOperation.h"
#import "CLUpdater.h"
#import "NSView+ClExtensions.h"
#import "RACHTTPClient.h"

#define kCLUpdatePath @"CLUpdatePath"
#define CLUpdateCheckInterval 60 * 60 * 1 // Every hour

static NSURL *UpdatesFolder(BOOL shouldCreate) {
    NSURL *updatesFolder = [AppDataDir() URLByAppendingPathComponent:@"updates"];
    if (shouldCreate)
        [FM createDirectoryAtURL:updatesFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    return updatesFolder;
}

@interface CLUpdater()

@property (nonatomic, strong) NSTask *unzipTask;
@property (nonatomic, strong) WebView *webView;

@end

@implementation CLUpdater {
    __weak RACSignal *_checkingSignal; // We take advantage of the fact signal gets deallocated without subscribers
    RACDisposable *_timerDisposable;
}

- (id)init {
    if (self = [super init]) {
        if ([FM fileExistsAtPath:[UD objectForKey:kCLUpdatePath]])
            _updateReady = YES;
    }
    return self;
}

- (WebView *)webView { return _webView ?: (_webView = [[WebView alloc] init]); }

- (NSPanel *)releaseNotesPanel {
    if (!_releaseNotesPanel) {
        int style = NSHUDWindowMask|NSUtilityWindowMask|NSClosableWindowMask|NSTitledWindowMask;
        _releaseNotesPanel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600) styleMask:style
                                                          backing:NSBackingStoreBuffered defer:YES];

        [[_releaseNotesPanel contentView] addSubview:self.webView];
        [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.webView constrainFillSuperview];
    }
    return _releaseNotesPanel;
}

#pragma mark Private Methods

- (BOOL)_launchUpdateHelperWithUpdatePath:(NSString *)updatePath {
    NSParameterAssert(updatePath);
    NSURL *embeddedHelperURL = [[NSBundle mainBundle] URLForResource:@"UpdateHelper" withExtension:nil];
    NSURL *helperURL = [UpdatesFolder(YES) URLByAppendingPathComponent:[embeddedHelperURL lastPathComponent]];
    
    if ([helperURL checkResourceIsReachableAndReturnError:NULL])
        [FM removeItemAtURL:helperURL error:NULL];
    
    NSError *error;
    if ([FM copyItemAtURL:embeddedHelperURL toURL:helperURL error:&error]) {
        NSArray *args = @[
            [[[NSBundle mainBundle] bundleURL] path],                     // App Path
            updatePath,                                                   // Update Path
            [UpdatesFolder(NO) path],                                     // Clean Path
            $str(@"%d", [[NSProcessInfo processInfo] processIdentifier]), // Parent Process ID
            @"1",                                                         // Should Relaunch
        ];
        
        LogInfo(@"updater", @"Updating app. Launching helper %@ args %@", helperURL.path, args);
        [NSTask launchedTaskWithLaunchPath:helperURL.path arguments:args];
        return YES;
    } else {
        [[NSAlert alertWithError:error] runModal];
        return NO;
    }
}

- (RACSignal *)_prepareUpdateForURL:(NSURL *)updateURL {
    NSParameterAssert(updateURL);
    [UD setObject:updateURL.path forKey:kCLUpdatePath];
    [UD synchronize];
    self.updateReady = YES;
    LogInfo(@"updater", @"Update at %@ is ready to be installed", updateURL.path);
    return [RACSignal return:updateURL.path];
}

- (RACSignal *)_unarchiveUpdateAtURL:(NSURL *)archiveURL {
    NSParameterAssert(archiveURL);
    self.unzipTask = [[NSTask alloc] init];
    [self.unzipTask setLaunchPath:@"/usr/bin/unzip"]; //this is where the unzip application is on the system.
    [self.unzipTask setCurrentDirectoryPath:archiveURL.URLByDeletingLastPathComponent.path];
    [self.unzipTask setArguments:@[@"-oq", archiveURL.path]];
    return [[self.unzipTask rac_run] sequenceNext:^RACSignal *{
        if ([self.unzipTask terminationStatus] == 0) {
            NSFileManager *fm = [[NSFileManager alloc] init];
            NSDirectoryEnumerator *dirEnum = [fm enumeratorAtURL:[archiveURL URLByDeletingLastPathComponent]
                                      includingPropertiesForKeys:nil
                                                         options:NSDirectoryEnumerationSkipsPackageDescendants
                                                                |NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                    errorHandler:NULL];
            
            for (NSURL *url in dirEnum)
                if ([url.pathExtension.lowercaseString isEqualToString:@"app"])
                    return [self _prepareUpdateForURL:url];
        }
        return [RACSignal error:$error(@"Cannot find updateURL")];
    }];
    LogInfo(@"updater", @"Unzipping archive %@", archiveURL.path);
}

- (RACSignal *)_downloadUpdate:(NSDictionary *)update {
    NSParameterAssert(update);
    // if for whatever reason updates already dir exists, let's do some cleanup first
    NSError *error = nil;
    if ([UpdatesFolder(NO) checkResourceIsReachableAndReturnError:NULL]) {
        LogInfo(@"updater", @"Cleaning updates folder %@", UpdatesFolder(NO));
        [FM removeItemAtURL:UpdatesFolder(NO) error:&error];
    }
    
    if (!update[@"download_url"] || error)
        return [RACSignal error:error];

    NSURLRequest *req = [[RACHTTPClient sharedClient] requestWithMethod:@"GET" path:update[@"download_url"] parameters:nil];
    CLDownloadOperation *op = [[CLDownloadOperation alloc] initWithRequest:req
                                                              targetFolder:UpdatesFolder(YES)];
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        LogDebug(@"updater", @"Update download is %f%% complete", 100.0 * totalBytesRead / totalBytesExpectedToRead);
    }];
    return [[[RACHTTPClient sharedClient] enqueueOperation:op] sequenceNext:^RACSignal *{
        LogDebug(@"updater", @"Successfully downloaded update to %@", op.finalURL);
        return [self _unarchiveUpdateAtURL:op.finalURL];
    }];
}

- (RACSignal *)_checkForUpdates {
    if (!_checkingSignal) {
        NSDictionary *params = @{
            @"version":    AppVersion(),
            @"build":      @(AppBuildNumber()),
            @"os_version": SystemVersion(),
            @"platform":   @"mac",
        };
        _checkingSignal = [[[[RACHTTPClient sharedClient] getPath:@"/meta/updates" parameters:params] map:^(NSHTTPURLResponse *response) {
            return response.json[@"update"];
        }] replayLazily];
    }
    return _checkingSignal;
}

#pragma mark Public Methods

- (void)checkForUpdatesInBackground {
    [[[self _checkForUpdates] flattenMap:^RACStream *(NSDictionary *update) {
        return update ? [self _downloadUpdate:update] : [RACSignal empty];
    }] subscribeNext:^(id x) {
        [self installUpdateWithAlert:nil];
    } error:^(NSError *error) {
        LogError(@"updater", @"Error while checking updates in background %@", error);
    }];
}

- (void)startAutoUpdater {
    NSAssert(!_timerDisposable, @"Cannot start autoUpdater twice");
    
    [self installUpdateIfReady:self];
    _timerDisposable = [[[RACSignal interval:CLUpdateCheckInterval withLeeway:60] startWith:[NSDate date]] subscribeNext:^(id x) {
        [self checkForUpdatesInBackground];
    }];
}

#pragma mark Target Action

- (IBAction)installUpdateIfReady:(id)sender {
    NSString *updatePath = [UD objectForKey:kCLUpdatePath];
    if (updatePath && [FM fileExistsAtPath:updatePath]) {
        if ([self _launchUpdateHelperWithUpdatePath:updatePath]) {
            [UD removeObjectForKey:kCLUpdatePath];
            [UD synchronize];
            [NSApp terminate:self];
        }
    }
}

- (IBAction)installUpdateWithAlert:(id)sender {
    if ([[NSApp mainWindow] isVisible]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Update Ready" defaultButton:@"Relaunch Now"
                                       alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        NSDate *start = [NSDate date];
        [[[RACSignal interval:1] startWith:start] subscribeNext:^(id x) {
            NSInteger left = 10 + start.timeIntervalSinceNow;
            alert.informativeText = $str(@"Auto relaunching in %ld seconds", left);
            if (left <= 0)
                [NSApp abortModal];
        }];
        [alert runModal];
    }
    [self installUpdateIfReady:nil];
}

- (IBAction)checkForUpdatesWithUI:(id)sender {
    [[[self _checkForUpdates] flattenMap:^RACStream *(NSDictionary *update) {
        __block NSInteger ret;
        if (update) {
            ret = [[NSAlert alertWithMessageText:@"Update found" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil
                        informativeTextWithFormat:@"Your current version is %@-%ld. Latest version is %@-%@. "
                                                  @"Click OK to download and install update",
                    AppVersion(), AppBuildNumber(), update[@"version"], update[@"build"]
                    ] runModal];
            if (ret == NSAlertDefaultReturn) {
                return [[[self _downloadUpdate:update] doNext:^(NSString *updatePath) {
                    [self installUpdateWithAlert:nil];
                }] replay];
            }
        } else {
            [[NSAlert alertWithMessageText:@"Up to date" defaultButton:@"OK" alternateButton:nil otherButton:nil
                 informativeTextWithFormat:@"Already running the latest version %@-%ld", AppVersion(), AppBuildNumber()] runModal];
        }
        return [RACSignal empty];
    }] subscribeError:^(NSError *error) {
        [NSApp presentError:error];
    }];
}

- (IBAction)showReleaseNotes:(id)sender {
    NSString *url = @"http://collections.me/release-notes";
    [self.webView setMainFrameURL:url];
    [self.releaseNotesPanel center];
    [self.releaseNotesPanel makeKeyAndOrderFront:nil];
}

#pragma mark WebView Delegate

#pragma mark Class Method

+ (id)sharedUpdater {
    static dispatch_once_t onceQueue;
    static CLUpdater *__updater = nil;
    
    dispatch_once(&onceQueue, ^{ __updater = [[self alloc] init]; });
    return __updater;
}

@end
