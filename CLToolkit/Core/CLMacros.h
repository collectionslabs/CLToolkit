//
//  CLMacros.h
//  Collections
//
//  Created by Tony Xiao on 6/25/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#ifndef Collections_CLMacros_h
#define Collections_CLMacros_h

// Globally accessible functions

NSURL *AppTempDir(void);
NSURL *AppCacheDir(void);
NSURL *AppDataDir(void);

NSString *SystemVersion(void);
NSString *AppVersion(void);
NSInteger AppBuildNumber(void);

void Log(NSString *format, ...);
void LogImage(NSImage *image);
void PrintManagedObjects(NSSet *objects);

NSError *ErrorFromException(NSException *exception);

NSComparator ComparatorFromSortDescriptors(NSArray *sortDescriptors);

@class WebScriptObject;
WebScriptObject *ToWebScript(WebScriptObject *windowScriptObject, id json);
id FromWebScript(WebScriptObject *windowScriptObject, WebScriptObject *webScriptObject);

void TransformToForegroundApplication(void);
void TransformToAccessoryApplication(void);

// Global Logging and Assertion Support
#if DEBUG
    #define JSON_WRITING_OPTIONS NSJSONWritingPrettyPrinted
    #define PLIST_WRITING_OPTIONS NSPropertyListMutableContainersAndLeaves
    #define MAX_LOGIMAGE_DIMENSION 64.0

    #define LogCritical(tag, ...)    LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 0, __VA_ARGS__)
    #define LogError(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 1, __VA_ARGS__)
    #define LogWarning(tag, ...)     LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 2, __VA_ARGS__)
    #define LogInfo(tag, ...)        LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 3, __VA_ARGS__)
    #define LogDebug(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 4, __VA_ARGS__)
    #define LogTrace(tag, ...)       LogMessageF(__FILE__, __LINE__, __FUNCTION__, tag, 5, __VA_ARGS__)

    #define AssertMainThread()       NSAssert([NSThread isMainThread], @"%s must be called from the main thread", __FUNCTION__)
    #define DOIF(cond, statement)    if (cond) { statement; }
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
    #define DOIF(cond, statement)
#endif

#define APP_IDENTIFIER [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]

// Global Shortcuts
#define NOT_NIL(obj)                    (obj ?: [NSNull null])
#define NOT_NSNULL(obj)                 ([[NSNull null] isEqual:obj] ? nil : obj)
#define LS(key)                         NSLocalizedString(key, nil)
#define $indexset(loc, len)             [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)]
#define $pred(...)                      [NSPredicate predicateWithFormat:__VA_ARGS__]
#define $url(str)                       [NSURL URLWithString:str]
#define $fileurl(path)                  [NSURL fileURLWithString:path]
#define $urlreq(url)                    [NSURLRequest requestWithURL:url]
#define $sort(a,b)                      [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b)]
#define $ssort(a,b,c)                   [NSSortDescriptor sortDescriptorWithKey:(a) ascending:(b) selector:(c)]
#define $error(desc)                    [NSError errorWithDomain:@"App" code:-1 userInfo:@{NSLocalizedDescriptionKey: desc ?: @"Unknown Error"}]
#define $vars(...)                       NSDictionaryOfVariableBindings(__VA_ARGS__)
#define $constraints(format, opts, vars) [NSLayoutConstraint constraintsWithVisualFormat:format \
                                             options:opts metrics:nil views:vars]

#define CONTEXT      [NSManagedObjectContext defaultContext]
#define NC           [NSNotificationCenter defaultCenter]
#define FM           [NSFileManager defaultManager]
#define UD           [NSUserDefaults standardUserDefaults]

#define JSON_DUMPS_DATA(obj)  (obj ? [NSJSONSerialization dataWithJSONObject:obj options:JSON_WRITING_OPTIONS error:NULL] : nil)
#define JSON_LOADS_DATA(data) (data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] : nil)
#define JSON_DUMPS(obj)  (obj ? [[NSString alloc] initWithData:JSON_DUMPS_DATA(obj) encoding:NSUTF8StringEncoding] : nil)
#define JSON_LOADS(str)  (str ? JSON_LOADS_DATA([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)

#define PLIST_DUMPS_DATA(obj) (obj ? [NSPropertyListSerialization dataWithPropertyList:obj format:NSPropertyListXMLFormat_v1_0 options:PLIST_WRITING_OPTIONS error:NULL] : nil)
#define PLIST_LOADS_DATA(data) (data ? [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL] : nil)
#define PLIST_DUMPS(obj) (obj ? [[NSString alloc] initWithData:PLIST_DUMPS_DATA(obj) encoding:NSUTF8StringEncoding] : nil)
#define PLIST_LOADS(str) (str ? PLIST_LOADS_DATA([str dataUsingEncoding:NSUTF8StringEncoding]) : nil)

#define ARCHIVE(obj)    [NSKeyedArchiver archivedDataWithRootObject:obj]
#define UNARCHIVE(data) [NSKeyedUnarchiver unarchiveObjectWithData:data]

#define INDICES_IN_RANGE(loc, len) [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)]

#define STANDARD_SIBLING_SPACING 8
#define STANDARD_SUPERVIEW_SPACING 20

#endif
