//
//  GrowingTKNavigationController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/13.
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

#import "GrowingTKNavigationController.h"

@interface GrowingTKNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation GrowingTKNavigationController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != self.interactivePopGestureRecognizer) {
        return YES;
    }

    return self.childViewControllers.count > 1;
}

#pragma mark - Override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
