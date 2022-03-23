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

@implementation UIViewController (GrowingTK)

#pragma mark Swizzle

+ (void)load {
#ifdef DEBUG
    [self growingtk_swizzleMethod:@selector(viewWillAppear:)
                       withMethod:@selector(growingtk_viewWillAppear:)
                            error:nil];
#endif
}

- (void)growingtk_viewWillAppear:(BOOL)animated {
    NSString *prefix = @"GrowingTK";
    if ([NSStringFromClass(self.class) hasPrefix:prefix]
        || [NSStringFromClass(self.navigationController.class) hasPrefix:prefix]
        || [NSStringFromClass(self.presentingViewController.class) hasPrefix:prefix]) {
        [GrowingTKSDKUtil.sharedInstance ignoreViewController:self];
    }
    
    [self growingtk_viewWillAppear:animated];
}

- (CGRect)growingtk_fullscreen {
    CGRect screen = self.view.bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            CGSize size = self.view.growingtk_size;
            if (size.width > size.height) {
                UIEdgeInsets safeAreaInsets = self.view.growingtk_safeAreaInsets;
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

@end
