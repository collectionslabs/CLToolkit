//
//  RACAppDelegate.m
//  Pods
//
//  Created by Tony Xiao on 8/3/13.
//
//

#import "RACAppDelegate.h"

@implementation RACAppDelegate {
    RACSubject *_onLocalNotification;
    RACSubject *_onRemoteNotification;
    RACSubject *_remoteNotificationRegistration;
}

#if TARGETING_IOS
@synthesize window = _window; // Explicit synthesis needed as property declared in protocol
#endif

- (RACSignal *)onLocalNotification {
    return _onLocalNotification ?: (_onLocalNotification = [RACReplaySubject replaySubjectWithCapacity:1]);
}

- (RACSignal *)onRemoteNotification {
    return _onRemoteNotification ?: (_onRemoteNotification = [RACReplaySubject replaySubjectWithCapacity:1]);
}

- (RACSignal *)registerForRemoteNotificationTypes:(NOTIFICATION_OPTIONS_TYPE)types {
    _remoteNotificationRegistration = [RACReplaySubject subject];
    [[APPLICATION_CLASS sharedApplication] registerForRemoteNotificationTypes:types];
    return _remoteNotificationRegistration;
}

- (RACSignal *)registerForAllRemoteNotifications {
#if TARGETING_IOS
    UIRemoteNotificationType types = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability;
#elif TARGETING_MAC
    NSRemoteNotificationType types = NSRemoteNotificationTypeAlert|NSRemoteNotificationTypeBadge|NSRemoteNotificationTypeSound|NSRemoteNotificationTypeNewsstandContentAvailability;
#endif
    return [self registerForRemoteNotificationTypes:types];
}

#pragma mark UI/NS AppDelegate Protocol Implementation

- (void)application:(APPLICATION_CLASS *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [_remoteNotificationRegistration sendNextAndComplete:deviceToken];
}

- (void)application:(APPLICATION_CLASS *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [_remoteNotificationRegistration sendError:error];
    LogError(@"Failed to register for remote notification %@", error);
}

- (void)application:(APPLICATION_CLASS *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_onRemoteNotification sendNext:userInfo];
}

#if TARGETING_IOS
- (void)application:(APPLICATION_CLASS *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [_onLocalNotification sendNext:notification];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey])
            [(RACSubject *)self.onLocalNotification sendNext:launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
        if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
            [(RACSubject *)self.onRemoteNotification sendNext:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    });
    return YES;
}

#endif


@end
