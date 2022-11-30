//
//  GrowingTKBaseViewController.m
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

#import "GrowingTKBaseViewController.h"
#import "GrowingTKNavigationItemView.h"
#import "UIColor+GrowingTK.h"
#import "UIView+GrowingTK.h"

@interface GrowingTKBaseViewController ()

@end

@implementation GrowingTKBaseViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // NavigationBar
//    self.navigationController.navigationBar.translucent = NO;
    UIColor *titleColor = UIColor.growingtk_labelColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(36)],
        NSForegroundColorAttributeName: titleColor
    }];

    // NavigationItem - Back
    if (self.navigationController.viewControllers.count > 1) {
        __weak typeof(self) weakSelf = self;
        GrowingTKNavigationItemView *customView = [[GrowingTKNavigationItemView alloc]
            initBackButtonWithFrame:CGRectMake(0, 0, 60, 44)
                             action:^{
                                 [weakSelf.navigationController popViewControllerAnimated:YES];
                             }];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
        self.navigationItem.leftBarButtonItems = @[item];
    }

    // Dark Mode
    self.view.backgroundColor = UIColor.growingtk_bg_1;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Toast

- (void)showToast:(NSString *)message {
    [self.view growingtk_makeToast:message];
}

- (void)hideToast {
    [self.view growingtk_hideAllToasts];
}

@end
