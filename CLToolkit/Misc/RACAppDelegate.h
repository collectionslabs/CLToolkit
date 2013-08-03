//
//  RACAppDelegate.h
//  Pods
//
//  Created by Tony Xiao on 8/3/13.
//
//

#import "Core.h"
#import "Misc.h"

#if TARGETING_IOS
#define APPLICATION_CLASS UIApplication
#define NOTIFICATION_OPTIONS_TYPE UIRemoteNotificationType
#elif TARGETING_OSX
#define APPLICATION_CLASS NSApplication
#define NOTIFICATION_OPTIONS_TYPE NSRemoteNotificationType
#endif

#if TARGETING_OSX

@interface RACAppDelegate : NSObject <NSApplicationDelegate>

#elif TARGETING_IOS

@interface RACAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, readonly) RACSignal *onLocalNotification;

#endif

@property (nonatomic, readonly) RACSignal *onRemoteNotification;

- (RACSignal *)registerForRemoteNotificationTypes:(NOTIFICATION_OPTIONS_TYPE)types;
- (RACSignal *)registerForAllRemoteNotifications;

@end
