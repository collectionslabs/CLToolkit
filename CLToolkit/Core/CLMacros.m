//
//  CLMacros.m
//  Collections
//
//  Created by Tony Xiao on 7/1/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "CLMacros.h"
#import "NSString+Concise.h"
#import <WebKit/WebKit.h>

void PrintManagedObjects(NSSet *objects) {
    for (id obj in objects) {
        NSString *title = [obj respondsToSelector:@selector(title)] ? [obj title] : nil;
        NSString *oid = [[[[obj objectID ] URIRepresentation] absoluteString] captureRegex:@"^.*?/p__cl_(.*)$" groupIndex:1];
        
        NSLog(@"\t%50s\t%15s\t%@", [oid UTF8String], [[[obj class] description] UTF8String], title);
    }
}

void Log(NSString *format, ...) {
#if  0
	va_list args;
	va_start(args, format);
    LogMessageTo_va(NULL, nil, 0, format, args);
	va_end(args);
#endif
}

void LogImage(NSImage *image) {
#if  0
    NSData *data = [image TIFFRepresentation];
    double ratio = MAX(image.size.width, image.size.height) / MAX_LOGIMAGE_DIMENSION;
    LogImageData(NULL, 0, (int)(image.size.width/ratio) , (int)(image.size.height/ratio), data);
#endif
}


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

NSError *ErrorFromException(NSException *exc) {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exc.name forKey:NSLocalizedDescriptionKey];
    [info setValue:exc.reason forKey:NSLocalizedFailureReasonErrorKey];
    [info setValue:exc.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
    [info setValue:exc.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
    [info setValue:exc.userInfo forKey:@"ExceptionUserInfo"];
    return [[NSError alloc] initWithDomain:exc.name code:0 userInfo:info];
}

WebScriptObject *ToWebScript(WebScriptObject *windowScriptObject, id json) {
    WebScriptObject *parser = [windowScriptObject valueForKey:@"JSON"];
    return [parser callWebScriptMethod:@"parse" withArguments:@[JSON_DUMPS(json)]];
}

id FromWebScript(WebScriptObject *windowScriptObject, WebScriptObject *webScriptObject) {
    WebScriptObject *parser = [windowScriptObject valueForKey:@"JSON"];
    return JSON_LOADS([parser callWebScriptMethod:@"stringify" withArguments:@[webScriptObject]]);
}


void TransformToForegroundApplication() {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    SetFrontProcess(&psn);
}

void TransformToAccessoryApplication() {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}

