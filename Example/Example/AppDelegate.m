//
//  AppDelegate.m
//  GrowingExample
//
//  Created by GrowingIO on 14/03/2018.
//  Copyright © 2018 GrowingIO. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreServices/CoreServices.h>
static NSString *const kGrowingProjectId = @"91eaf9b283361032";

#ifdef DEBUG
#import <GrowingToolsKit/GrowingToolsKit.h>
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    [GrowingToolsKit start];
#endif
#if SDK3rd
    GrowingSDKConfiguration *configuration = [GrowingSDKConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
    configuration.encryptEnabled = YES;
    configuration.dataCollectionServerHost = @"http://uat-api.growingio.com";
    //    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";
    [GrowingSDK startWithConfiguration:configuration launchOptions:launchOptions];
#elif SDK2nd
    [Growing setEnableLog:YES];
    [Growing setFlushInterval:3.0f];
    [Growing startWithAccountId:@"0a1b4118dd954ec3bcc69da5138bdb96"];
#endif
    // 自动化测试会有授权弹窗
    //   [self registerRemoteNotification];

    return YES;
}

#pragma mark - Notification

- (void)registerRemoteNotification {
    if (@available(iOS 10, *)) {
        //  10以后的注册方式
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //监听回调事件
        // iOS 10 使用以下方法注册，才能得到授权，注册通知以后，会自动注册 deviceToken，如果获取不到
        // deviceToken，Xcode8下要注意开启 Capability->Push Notification。
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                  if (granted) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [[UIApplication sharedApplication] registerForRemoteNotifications];
                                      });
                                  }
                              }];

    } else if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =
            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (NSInteger i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i] & 0xff];
    }

    NSLog(@"推送Token 字符串：%@", deviceTokenString);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知1"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}

#pragma mark - Life Cycle

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"状态** 将要进入前台");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"状态** 已经活跃");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"状态** 将要进入后台");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"状态** 已经进入后台");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"状态** 将要退出程序");
}

#pragma mark - Handler

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
#if SDK2nd
    [Growing handleUrl:url];
#endif
    return NO;
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
#if SDK2nd
    [Growing handleUrl:userActivity.webpageURL];
#endif
    restorationHandler(nil);
    return YES;
}

@end
