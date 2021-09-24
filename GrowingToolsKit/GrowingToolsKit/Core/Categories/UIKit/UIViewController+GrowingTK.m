//
//  UIViewController+GrowingTK.m
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

#import "UIViewController+GrowingTK.h"
#import "NSObject+GrowingTKSwizzle.h"
#import "GrowingTKSDKUtil.h"
#import "UIView+GrowingTK.h"
#import "GrowingTKUtil.h"
#import "GrowingTKHomeWindow.h"

@implementation UIViewController (GrowingTK)

#pragma mark Swizzle

+ (void)load {
    [self growingtk_swizzleMethod:@selector(viewWillAppear:)
                       withMethod:@selector(growingtk_viewWillAppear:)
                            error:nil];
}

- (void)growingtk_viewWillAppear:(BOOL)animated {
    if ([NSStringFromClass(self.class) hasPrefix:@"GrowingTK"]
        || [NSStringFromClass(self.navigationController.class) hasPrefix:@"GrowingTK"]
        || [NSStringFromClass(self.presentingViewController.class) hasPrefix:@"GrowingTK"]) {
        [GrowingTKSDKUtil.sharedInstance ignoreViewController:self];
    }
    
    [self growingtk_viewWillAppear:animated];
}

- (UIEdgeInsets)growingtk_safeAreaInset:(UIView *)view {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (UILayoutGuide *)growingtk_safeAreaLayoutGuide {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaLayoutGuide;
    }
    return self.view.layoutMarginsGuide;
}

- (UIEdgeInsets)growingtk_safeAreaInset {
    return [self growingtk_safeAreaInset:self.view];
}

- (CGRect)growingtk_fullscreen {
    CGRect screen = self.view.bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            CGSize size = self.view.growingtk_size;
            if (size.width > size.height) {
                UIEdgeInsets safeAreaInsets = [self growingtk_safeAreaInset];
                CGRect frame = screen;
                CGFloat width = self.view.growingtk_width - safeAreaInsets.left - safeAreaInsets.right;
                frame.origin.x = safeAreaInsets.left;
                frame.size.width = width;
                screen = frame;
            }
        } break;
        default:
            screen = screen;
            break;
    }

    return screen;
}

+ (UIViewController *)growingtk_rootViewControllerForKeyWindow {
    return GrowingTKUtil.keyWindow.rootViewController;
}

+ (UIViewController *)growingtk_topViewControllerForKeyWindow {
    UIViewController *controller = [self growingtk_topViewController:GrowingTKUtil.keyWindow.rootViewController];
    while (controller.presentedViewController) {
        [self growingtk_topViewController:controller.presentedViewController];
    }
    return controller;
}

+ (UIViewController *)growingtk_topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self growingtk_topViewController:[(UINavigationController *)controller topViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self growingtk_topViewController:[(UITabBarController *)controller selectedViewController]];
    } else {
        return controller;
    }
    return nil;
}

+ (UIViewController *)growingtk_rootViewControllerForHomeWindow {
    return GrowingTKHomeWindow.sharedInstance.rootViewController;
}

@end
