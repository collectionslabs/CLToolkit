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

NSURL *AppDataDir(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];
    NSURL *appDataDir = [appSupportDir URLByAppendingPathComponent:APP_IDENTIFIER];
    [fm createDirectoryAtURL:appDataDir withIntermediateDirectories:YES attributes:nil error:NULL];
    return appDataDir;
}


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

NSString *AppVersion(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

NSInteger AppBuildNumber(void) {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
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

// Global Logging and assertion support

void Log(NSString *format, ...) {
#if DEBUG
	va_list args;
	va_start(args, format);
    LogMessageTo_va(NULL, nil, 0, format, args);
	va_end(args);
#endif
}

void LogImage(NSImage *image) {
#if DEBUG
    NSData *data = [image TIFFRepresentation];
    double ratio = MAX(image.size.width, image.size.height) / MAX_LOGIMAGE_DIMENSION;
    LogImageData(NULL, 0, (int)(image.size.width/ratio) , (int)(image.size.height/ratio), data);
#endif
}
