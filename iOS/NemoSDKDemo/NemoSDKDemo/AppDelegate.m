//
//  AppDelegate.m
//  NemoSDK
//
//  Created by 杨旭东 on 16/9/28.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) UIBackgroundTaskIdentifier identifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (granted) {
//            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//            content.title = @"NemoSDK";
//            content.subtitle = @"Comming Call";
//            content.body = @"This is JackYang,the notification just for test";
//            content.sound = [UNNotificationSound defaultSound];
//            
//            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:15.0f repeats:NO];
//            UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"NemoTestNotification" content:content trigger:trigger];
//            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
//                if (!error) {
//                    NSLog(@"add local notification success");
//                }
//            }];
//        }
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([_controller isMemberOfClass:[ConnectedCallController class]]) {
        TabbarController *tab = (TabbarController *)self.window.rootViewController;
        [tab setNewOrientation:YES];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
