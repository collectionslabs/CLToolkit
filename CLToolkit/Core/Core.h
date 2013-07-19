//
//  Core.h
//  Collections
//
//  Created by Tony Xiao on 6/25/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

/*
 Dependencies: 
    - Cocoa / UIKit (Maybe we can reduce it to Foundation)
    - ReactiveCocoa
    - ConciseKit
    - BlocksKit
    - NSLogger
    - ISO8601Formatter
    - objc
    - CommonCrypto
 */

#ifndef CLToolkit_Core_h
#define CLToolkit_Core_h

#import <Cocoa/Cocoa.h>
#import <ConciseKit/ConciseKit.h>
#import <BlocksKit/BlocksKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import <NSLogger/LoggerClient.h>

#import "NSObject+Core.h"
#import "NSString+Core.h"
#import "NSArray+Core.h"
#import "NSDictionary+Core.h"
#import "NSDate+Core.h"
#import "NSColor+Core.h"
#import "ReactiveCocoa+Core.h"

// Globally accessible functions

NSURL *AppTempDir(void);
NSURL *AppCacheDir(void);
NSURL *AppDataDir(void);

NSString *SystemVersion(void);
NSString *AppVersion(void);
NSInteger AppBuildNumber(void);

NSError *ErrorFromException(NSException *exception);

NSComparator ComparatorFromSortDescriptors(NSArray *sortDescriptors);

// Global Logging and Assertion Support

void Log(NSString *format, ...);
void LogImage(NSImage *image);

#if DEBUG
    #define JSON_WRITING_OPTIONS NSJSONWritingPrettyPrinted
    #define PLIST_WRITING_OPTIONS NSPropertyListMutableContainersAndLeaves
    #define MAX_LOGIMAGE_DIMENSION 64.0
    // TODO: make tag optional and definable via static str
    #define LogCritical(tag, ...)    LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 0, __VA_ARGS__)
    #define LogError(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 1, __VA_ARGS__)
    #define LogWarning(tag, ...)     LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 2, __VA_ARGS__)
    #define LogInfo(tag, ...)        LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 3, __VA_ARGS__)
    #define LogDebug(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 4, __VA_ARGS__)
    #define LogTrace(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 5, __VA_ARGS__)

    #define AssertMainThread()       NSAssert([NSThread isMainThread], @"%s must be called from the main thread", __FUNCTION__)
#else
    #define JSON_WRITING_OPTIONS 0
    #define PLIST_WRITING_OPTIONS 0

    #define LogCritical(tag, ...)
    #define LogError(tag, ...)
    #define LogWarning(tag, ...)
    #define LogInfo(tag, ...)
    #define LogDebug(tag, ...)
    #define LogTrace(tag, ...)

    #define LogMarker(...)
    #define LoggerFlush(...)
    #define LoggerSetViewerHost(...) 

    #define AssertMainThread()
#endif

// Global Constants & Singletons

#define UIApp                      [UIApplication sharedApplication]
#define CONTEXT                    [NSManagedObjectContext defaultContext]
#define NC                         [NSNotificationCenter defaultCenter]
#define FM                         [NSFileManager defaultManager]
#define UD                         [NSUserDefaults standardUserDefaults]
#define APP_IDENTIFIER             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]

#define STANDARD_SIBLING_SPACING   8
#define STANDARD_SUPERVIEW_SPACING 20

// Global Shortcuts
#define $safeNil(obj)                    (obj ?: [NSNull null])
#define $safeNull(obj)                   ([[NSNull null] isEqual:obj] ? nil : obj)
#define $ls(key)                         NSLocalizedString(key, nil)
#define $indexset(loc, len)              [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)]
#define $pred(...)                       [NSPredicate predicateWithFormat:__VA_ARGS__]
#define $url(str)                        [NSURL URLWithString:str]
#define $fileurl(path)                   [NSURL fileURLWithString:path]
#define $urlreq(url)                     [NSURLRequest requestWithURL:url]
#define $sort(a,b)                       [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b)]
#define $ssort(a,b,c)                    [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b) selector:(c)]
#define $vars(...)                       NSDictionaryOfVariableBindings(__VA_ARGS__)
#define $error(desc)                     [NSError errorWithDomain:@"App" code:-1 userInfo: \
                                             @{NSLocalizedDescriptionKey: desc ?: @"Unknown Error"}]
#define $constraints(format, opts, vars) [NSLayoutConstraint constraintsWithVisualFormat:format \
                                             options:opts metrics:nil views:vars]

#define $jsonDumpsData(obj)              (obj ? [NSJSONSerialization dataWithJSONObject:obj options:JSON_WRITING_OPTIONS error:NULL] : nil)
#define $jsonLoadsData(data)             (data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] : nil)
#define $jsonDumps(obj)                  (obj ? [[NSString alloc] initWithData:$jsonDumpsData(obj) encoding:NSUTF8StringEncoding] : nil)
#define $jsonLoads(str)                  (str ? $jsonLoadsData([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)

#define $plistDumpsData(obj)             (obj ? [NSPropertyListSerialization dataWithPropertyList:obj format:NSPropertyListXMLFormat_v1_0 options:PLIST_WRITING_OPTIONS error:NULL] : nil)
#define $plistLoadsData(data)            (data ? [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL] : nil)
#define $plistDumps(obj)                 (obj ? [[NSString alloc] initWithData:$plistDumpsData(obj) encoding:NSUTF8StringEncoding] : nil)
#define $plistLoads(str)                 (str ? $plistLoadsData([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)

#define $archive(obj)                    [NSKeyedArchiver archivedDataWithRootObject:obj]
#define $unarchive(data)                 [NSKeyedUnarchiver unarchiveObjectWithData:data]

#endif
