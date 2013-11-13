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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define COLOR_CLASS UIColor
#define IMAGE_CLASS UIImage
#define TARGETING_IOS 1
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#define COLOR_CLASS NSColor
#define IMAGE_CLASS NSImage
#define TARGETING_OSX 1
#endif
#import <ConciseKit/ConciseKit.h>
#import <BlocksKit/BlocksKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import <CocoaLumberjack/DDLog.h>

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

#if !TARGET_OS_IPHONE
NSString *SystemVersion(void);
#endif
NSString *AppName(void);
NSString *AppVersion(void);
NSInteger AppBuildNumber(void);

NSError *ErrorFromException(NSException *exception);

NSComparator ComparatorFromSortDescriptors(NSArray *sortDescriptors);

// Global Logging and Assertion Support

void Log(NSString *format, ...);
void LogImage(IMAGE_CLASS *image);

#if DEBUG
    #define JSON_WRITING_OPTIONS NSJSONWritingPrettyPrinted
    #define PLIST_WRITING_OPTIONS NSPropertyListMutableContainersAndLeaves

    #define AssertMainThread()       NSAssert([NSThread isMainThread], @"%s must be called from the main thread", __FUNCTION__)
#else
    #define JSON_WRITING_OPTIONS 0
    #define PLIST_WRITING_OPTIONS 0
    #define AssertMainThread()
#endif

// Global Constants & Singletons

#if TARGET_OS_IPHONE
#define UIApp                      [UIApplication sharedApplication]
#define APP_DELEGATE               (id)[UIApp delegate]
#elif TARGET_OS_MAC
#define APP_DELEGATE               (id)[NSApp delegate]
#endif
#define CONTEXT                    [NSManagedObjectContext defaultContext]
#define NC                         [NSNotificationCenter defaultCenter]
#define FM                         [NSFileManager defaultManager]
#define UD                         [NSUserDefaults standardUserDefaults]
#define APP_IDENTIFIER             [[NSBundle mainBundle] bundleIdentifier]

#define STANDARD_SIBLING_SPACING   8
#define STANDARD_SUPERVIEW_SPACING 20

// Global Shortcuts
#define $nullify(obj)                    (obj ?: [NSNull null])
#define $nilify(obj)                     ([[NSNull null] isEqual:obj] ? nil : obj)
#define $ls(key)                         NSLocalizedString(key, nil)
#define $indexset(loc, len)              [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)]
#define $pred(...)                       [NSPredicate predicateWithFormat:__VA_ARGS__]
#define $url(str)                        ((NSURL *)[NSURL URLWithString:str])
#define $fileurl(path)                   ((NSURL *)[NSURL fileURLWithPath:path])
#define $urlreq(url)                     [NSURLRequest requestWithURL:url]
#define $sort(a,b)                       [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b)]
#define $ssort(a,b,c)                    [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b) selector:(c)]
#define $vars(...)                       NSDictionaryOfVariableBindings(__VA_ARGS__)
#define $error(desc)                     [NSError errorWithDomain:@"App" code:-1 userInfo: \
                                             @{NSLocalizedDescriptionKey: desc ?: @"Unknown Error"}]
#define $constraints(format, opts, vars) [NSLayoutConstraint constraintsWithVisualFormat:format \
                                             options:opts metrics:nil views:vars]
#define $attrStr(str)                    [[NSAttributedString alloc] initWithString:str]

#define $resourceURL(name)               [[NSBundle mainBundle] \
                                            URLForResource:[name stringByDeletingPathExtension] \
                                            withExtension:[name pathExtension]]

#define $jsonDumpsData(obj)              (obj ? [NSJSONSerialization dataWithJSONObject:obj options:JSON_WRITING_OPTIONS error:NULL] : nil)
#define $jsonLoadsData(data)             (data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] : nil)
#define $jsonDumps(obj)                  (obj ? [[NSString alloc] initWithData:$jsonDumpsData(obj) encoding:NSUTF8StringEncoding] : nil)
#define $jsonLoads(str)                  (str ? $jsonLoadsData([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)
#define $jsonLoadsURL(url)               (url ? $jsonLoadsData([NSData dataWithContentsOfURL:url]) : nil)
#define $jsonLoadsResource(name)         (name ? $jsonLoadsURL($resourceURL(name)) : nil)

#define $plistDumpsData(obj)             (obj ? [NSPropertyListSerialization dataWithPropertyList:obj format:NSPropertyListXMLFormat_v1_0 options:PLIST_WRITING_OPTIONS error:NULL] : nil)
#define $plistLoadsData(data)            (data ? [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL] : nil)
#define $plistDumps(obj)                 (obj ? [[NSString alloc] initWithData:$plistDumpsData(obj) encoding:NSUTF8StringEncoding] : nil)
#define $plistLoads(str)                 (str ? $plistLoadsData([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)

#define $archive(obj)                    [NSKeyedArchiver archivedDataWithRootObject:obj]
#define $unarchive(data)                 [NSKeyedUnarchiver unarchiveObjectWithData:data]

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
    static dispatch_once_t pred; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = block(); \
    }); \
    return _sharedObject; \

// credits to : https://gist.github.com/mwaterfall/953657
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define RUNNING_IOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_PHONE    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IN_BACKGROUND ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)

/************************ Logging *************************/

// Undefine everything defined by DDLog
#undef LOG_FLAG_ERROR
#undef LOG_FLAG_WARN
#undef LOG_FLAG_INFO
#undef LOG_FLAG_VERBOSE

#undef LOG_LEVEL_OFF
#undef LOG_LEVEL_ERROR
#undef LOG_LEVEL_WARN
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_VERBOSE

#undef LOG_ERROR
#undef LOG_WARN
#undef LOG_INFO
#undef LOG_VERBOSE

#undef LOG_ASYNC_ERROR
#undef LOG_ASYNC_WARN
#undef LOG_ASYNC_INFO
#undef LOG_ASYNC_VERBOSE

#undef DDLogError
#undef DDLogWarn
#undef DDLogInfo
#undef DDLogVerbose

#undef DDLogCError
#undef DDLogCWarn
#undef DDLogCInfo
#undef DDLogCVerbose

// Define our own log levels, following log4j conventions with 6 levels: Fatal, Error, Warn, Info, Debug and Trace
#define LOG_FLAG_FATAL    (1 << 0)  // 0......1
#define LOG_FLAG_ERROR    (1 << 1)  // 0.....10
#define LOG_FLAG_WARN     (1 << 2)  // 0....100
#define LOG_FLAG_INFO     (1 << 3)  // 0...1000
#define LOG_FLAG_DEBUG    (1 << 4)  // 0..10000
#define LOG_FLAG_TRACE    (1 << 5)  // 0.100000

#define LOG_LEVEL_OFF     0
#define LOG_LEVEL_FATAL   (LOG_FLAG_FATAL)                                                                                   // 0......1
#define LOG_LEVEL_ERROR   (LOG_FLAG_FATAL | LOG_FLAG_ERROR)                                                                  // 0.....11
#define LOG_LEVEL_WARN    (LOG_FLAG_FATAL | LOG_FLAG_ERROR | LOG_FLAG_WARN)                                                  // 0....111
#define LOG_LEVEL_INFO    (LOG_FLAG_FATAL | LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO)                                  // 0...1111
#define LOG_LEVEL_DEBUG   (LOG_FLAG_FATAL | LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO | LOG_FLAG_DEBUG)                 // 0..11111
#define LOG_LEVEL_TRACE   (LOG_FLAG_FATAL | LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO | LOG_FLAG_DEBUG |LOG_FLAG_TRACE) // 0.111111

#define LOG_FATAL   (kLogLevel & LOG_FLAG_FATAL)
#define LOG_ERROR   (kLogLevel & LOG_FLAG_ERROR)
#define LOG_WARN    (kLogLevel & LOG_FLAG_WARN)
#define LOG_INFO    (kLogLevel & LOG_FLAG_INFO)
#define LOG_DEBUG   (kLogLevel & LOG_FLAG_DEBUG)
#define LOG_TRACE   (kLogLevel & LOG_FLAG_TRACE)

#define LOG_ASYNC_FATAL   ( NO && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_ERROR   ( NO && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_WARN    (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_INFO    (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_DEBUG   (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_TRACE   (YES && LOG_ASYNC_ENABLED)

#define LogFatal(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_FATAL,   kLogLevel, LOG_FLAG_FATAL,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogError(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_ERROR,   kLogLevel, LOG_FLAG_ERROR,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogWarn(frmt, ...)     LOG_OBJC_TAG_MAYBE(LOG_ASYNC_WARN,    kLogLevel, LOG_FLAG_WARN,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogInfo(frmt, ...)     LOG_OBJC_TAG_MAYBE(LOG_ASYNC_INFO,    kLogLevel, LOG_FLAG_INFO,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogDebug(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_DEBUG,   kLogLevel, LOG_FLAG_DEBUG,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogTrace(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_TRACE,   kLogLevel, LOG_FLAG_TRACE,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)

#define LogCFatal(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_FATAL,      kLogLevel, LOG_FLAG_FATAL,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCError(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_ERROR,      kLogLevel, LOG_FLAG_ERROR,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCWarn(frmt, ...)    LOG_C_TAG_MAYBE(LOG_ASYNC_WARN,       kLogLevel, LOG_FLAG_WARN,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCInfo(frmt, ...)    LOG_C_TAG_MAYBE(LOG_ASYNC_INFO,       kLogLevel, LOG_FLAG_INFO,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCDebug(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_DEBUG,      kLogLevel, LOG_FLAG_DEBUG,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCTrace(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_TRACE,      kLogLevel, LOG_FLAG_TRACE,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)

// Default to DEBUG level when debugging, INFO otherwise
#ifdef DEBUG
    #define kLogLevel LOG_LEVEL_DEBUG
#else
    #define kLogLevel LOG_LEVEL_INFO
#endif
// Default to nil tag and 0 context
#define kLogTag nil
#define kLogContext 0

// Extended Image logging support from NSLogger
#define MAX_LOGIMAGE_DIMENSION 64.0
void LogImage(IMAGE_CLASS *image);


#endif
