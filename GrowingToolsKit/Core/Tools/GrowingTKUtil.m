//
//  GrowingTKUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GrowingTKUtil.h"
#import "GrowingTKHomeWindow.h"

@implementation GrowingTKUtil

+ (UIViewController *)topViewControllerForKeyWindow {
    UIViewController *controller = [self topViewController:GrowingTKUtil.keyWindow.rootViewController];
    while (controller.presentedViewController) {
        [self topViewController:controller.presentedViewController];
    }
    return controller;
}

+ (UIViewController *)topViewControllerForHomeWindow {
    UIViewController *controller = [self topViewController:GrowingTKHomeWindow.sharedInstance.rootViewController];
    while (controller.presentedViewController) {
        [self topViewController:controller.presentedViewController];
    }
    return controller;
}

+ (UIViewController *)topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)controller topViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)controller selectedViewController]];
    } else {
        return controller;
    }
    return nil;
}

+ (UIWindow *)keyWindow {
    UIWindow *keyWindow = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        keyWindow = [[UIApplication sharedApplication].delegate window];
    } else {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            if (!window.hidden) {
                keyWindow = window;
                break;
            }
        }
    }
    return keyWindow;
}

+ (void)openAppSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:^(BOOL success) {

                                     }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

+ (BOOL)isIPAddress:(NSString *)string {
    NSString *pre = @"((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pre];
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isDomain:(NSString *)string {
    NSString *pre = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pre];
    return [predicate evaluateWithObject:string];
}

@end
