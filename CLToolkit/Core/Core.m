//
//  Core.m
//  Collections
//
//  Created by Tony Xiao on 7/18/13.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"


NSURL *AppTempDir(void) {
    return [NSURL fileURLWithPath:NSTemporaryDirectory()];
}

NSURL *AppCacheDir(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *cacheDir = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
    NSURL *appCacheDir = [cacheDir URLByAppendingPathComponent:APP_IDENTIFIER];
    [fm createDirectoryAtURL:appCacheDir withIntermediateDirectories:YES attributes:nil error:NULL];
    return appCacheDir;
}

NSURL *AppDocumentsDirectory(void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [NSURL fileURLWithPath:paths.firstObject];
}

NSURL *AppDataDir(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];
    NSURL *appDataDir = [appSupportDir URLByAppendingPathComponent:APP_IDENTIFIER];
    [fm createDirectoryAtURL:appDataDir withIntermediateDirectories:YES attributes:nil error:NULL];
    return appDataDir;
}

#if !TARGET_OS_IPHONE
NSString *SystemVersion(void) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    OSErr err;
    SInt32 major, minor, bugfix;
    err = Gestalt(gestaltSystemVersionMajor, &major);
    if (err != noErr) return nil;
    err = Gestalt(gestaltSystemVersionMinor, &minor);
    if (err != noErr) return nil;
    err = Gestalt(gestaltSystemVersionBugFix, &bugfix);
    if (err != noErr) return nil;
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, bugfix];
}
#endif

NSString *AppName(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]
        ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

NSString *AppVersion(void) {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (!version.length)
        version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    return version;
}

NSInteger AppBuildNumber(void) {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] integerValue];
}

NSError *ErrorFromException(NSException *exc) {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exc.name forKey:NSLocalizedDescriptionKey];
    [info setValue:exc.reason forKey:NSLocalizedFailureReasonErrorKey];
    [info setValue:exc.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
    [info setValue:exc.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
    [info setValue:exc.userInfo forKey:@"ExceptionUserInfo"];
    return [[NSError alloc] initWithDomain:exc.name code:0 userInfo:info];
}

NSComparator ComparatorFromSortDescriptors(NSArray *sortDescriptors) {
    if (!sortDescriptors.count)
        return nil;
    return ^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        for (NSSortDescriptor *descriptor in sortDescriptors) {
            result = [descriptor compareObject:obj1 toObject:obj2];
            if (result != NSOrderedSame)
                return result;
        }
        return result;
    };
}

// Async Utils
dispatch_queue_t dispatch_queue_create_specific(const char *label, dispatch_queue_attr_t attr) {
    dispatch_queue_t queue = dispatch_queue_create(label, attr);
    dispatch_queue_set_specific(queue, (__bridge const void *)queue, (__bridge void *)queue, NULL);
    return queue;
}

BOOL dispatch_is_on_specific_queue(dispatch_queue_t queue) {
    return dispatch_get_specific((__bridge const void *)queue) != NULL;
}

void dispatch_specific(dispatch_queue_t queue, dispatch_block_t block, BOOL waitForCompletion) {
    if (dispatch_get_specific((__bridge const void *)queue)) {
        block();
    } else if (waitForCompletion) {
        dispatch_sync(queue, block);
    } else {
        dispatch_async(queue, block);
    }
}

void dispatch_specific_async(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_specific(queue, block, NO);
}

void dispatch_specific_sync(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_specific(queue, block, YES);
}
