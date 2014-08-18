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
#import <CocoaLumberjack/Cocoalumberjack.h>

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
NSURL *AppDocumentsDirectory(void);
NSURL *AppDataDir(void);

#if !TARGET_OS_IPHONE
NSString *SystemVersion(void);
#endif
NSString *AppName(void);
NSString *AppVersion(void);
NSInteger AppBuildNumber(void);

NSError *ErrorFromException(NSException *exception);

NSComparator ComparatorFromSortDescriptors(NSArray *sortDescriptors);

// Async Utils
dispatch_queue_t dispatch_queue_create_specific(const char *label, dispatch_queue_attr_t attr);
BOOL dispatch_is_on_specific_queue(dispatch_queue_t queue);
void dispatch_specific(dispatch_queue_t queue, dispatch_block_t block, BOOL waitForCompletion);
void dispatch_specific_async(dispatch_queue_t queue, dispatch_block_t block);
void dispatch_specific_sync(dispatch_queue_t queue, dispatch_block_t block);

// Global Logging and Assertion Support

void Log(NSString *format, ...);

#if DEBUG
    #define JSON_WRITING_OPTIONS NSJSONWritingPrettyPrinted
    #define PLIST_WRITING_OPTIONS NSPropertyListMutableContainersAndLeaves

#else
    #define JSON_WRITING_OPTIONS 0
    #define PLIST_WRITING_OPTIONS 0
#endif

#define AssertMainThread()    NSAssert([NSThread isMainThread], @"%s must be called from the main thread", __FUNCTION__)
#define AssertNotMainThread() NSAssert(![NSThread isMainThread], @"%s must NOT be called from the main thread", __FUNCTION__)

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
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IN_BACKGROUND ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)

/************************ Logging *************************/

#define LogError(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_ERROR,   kLogLevel, LOG_FLAG_ERROR,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogWarn(frmt, ...)     LOG_OBJC_TAG_MAYBE(LOG_ASYNC_WARN,    kLogLevel, LOG_FLAG_WARN,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogInfo(frmt, ...)     LOG_OBJC_TAG_MAYBE(LOG_ASYNC_INFO,    kLogLevel, LOG_FLAG_INFO,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogDebug(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_DEBUG,   kLogLevel, LOG_FLAG_DEBUG,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogTrace(frmt, ...)    LOG_OBJC_TAG_MAYBE(LOG_ASYNC_VERBOSE,   kLogLevel, LOG_FLAG_VERBOSE,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)

#define LogCError(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_ERROR,      kLogLevel, LOG_FLAG_ERROR,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCWarn(frmt, ...)    LOG_C_TAG_MAYBE(LOG_ASYNC_WARN,       kLogLevel, LOG_FLAG_WARN,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCInfo(frmt, ...)    LOG_C_TAG_MAYBE(LOG_ASYNC_INFO,       kLogLevel, LOG_FLAG_INFO,    kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCDebug(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_DEBUG,      kLogLevel, LOG_FLAG_DEBUG,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)
#define LogCTrace(frmt, ...)   LOG_C_TAG_MAYBE(LOG_ASYNC_VERBOSE,      kLogLevel, LOG_FLAG_VERBOSE,   kLogContext, kLogTag, frmt, ##__VA_ARGS__)

// Default to DEBUG level when debugging, INFO otherwise
#ifdef DEBUG
    #define kLogLevel LOG_LEVEL_DEBUG
#else
    #define kLogLevel LOG_LEVEL_INFO
#endif
// Default to nil tag and 0 context
#define kLogTag nil
#define kLogContext 0

#endif
