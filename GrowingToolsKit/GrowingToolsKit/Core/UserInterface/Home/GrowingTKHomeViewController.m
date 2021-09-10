//
//  GrowingTKHomeViewController.m
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

#import "GrowingTKHomeViewController.h"
#import "GrowingTKPluginsListViewController.h"
#import "GrowingTKSDKCheckViewController.h"
#import "GrowingTKEntryWindow.h"
#import "GrowingTKHomeWindow.h"
#import "GrowingTKModuleButton.h"
#import "UIColor+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIViewController+GrowingTK.h"

#define MAIN_VIEW_TOP (GrowingTKSizeFrom750(160) + IPHONE_STATUSBAR_HEIGHT)

@interface GrowingTKHomeViewController ()

@property (nonatomic, assign) UIStatusBarStyle kStatusBarStyle;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) GrowingTKModuleButton *pluginsButton;
@property (nonatomic, strong) GrowingTKModuleButton *checkButton;
@property (nonatomic, strong) UIImageView *triangleView;
@property (nonatomic, strong) GrowingTKPluginsListViewController *pluginsList;
@property (nonatomic, strong) GrowingTKSDKCheckViewController *checkSelf;
@property (nonatomic, strong) UIViewController *currentChild;

@end

@implementation GrowingTKHomeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.growingtk_black_alpha;
    [self.view addSubview:self.triangleView];
    [self.view addSubview:self.pluginsButton];
    [self.view addSubview:self.checkButton];
    [self.view addSubview:self.mainView];

    [self showCheckSelf];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Action

- (void)showChildController:(UIViewController *)child {
    if (self.currentChild) {
        [self.currentChild.view removeFromSuperview];
        [self.currentChild willMoveToParentViewController:nil];
        [self.currentChild removeFromParentViewController];
    }

    [self addChildViewController:child];
    [child didMoveToParentViewController:self];
    child.view.frame = self.mainView.bounds;
    [self.mainView addSubview:child.view];
    self.currentChild = child;
}

- (void)showPluginsList {
    if (self.currentChild == self.pluginsList) {
        [[GrowingTKHomeWindow sharedInstance] toggle];
        [[GrowingTKEntryWindow sharedInstance] toggle:GrowingTKModulePlugins];
        return;
    }
    [self showChildController:self.pluginsList];
    self.triangleView.growingtk_centerX = self.pluginsButton.growingtk_centerX;
}

- (void)showCheckSelf {
    if (self.currentChild == self.checkSelf) {
        [[GrowingTKHomeWindow sharedInstance] toggle];
        [[GrowingTKEntryWindow sharedInstance] toggle:GrowingTKModuleCheckSelf];
        return;
    }
    [self showChildController:self.checkSelf];
    self.triangleView.growingtk_centerX = self.checkButton.growingtk_centerX;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.kStatusBarStyle;
}

#pragma mark - Dark Mode

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self setNeedsStatusBarAppearanceUpdate];
            self.triangleView.image =
                UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
                    ? [UIImage growingtk_imageNamed:@"growingtk_triangle_black"]
                    : [UIImage growingtk_imageNamed:@"growingtk_triangle"];
        }
    }
}

#pragma mark - Getter & Setter

- (UIStatusBarStyle)kStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
                   ? UIStatusBarStyleDarkContent
                   : UIStatusBarStyleLightContent;
    }

    return UIStatusBarStyleDefault;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc]
            initWithFrame:CGRectMake(0, MAIN_VIEW_TOP, GrowingTKScreenWidth, GrowingTKScreenHeight - MAIN_VIEW_TOP)];
        _mainView.backgroundColor = UIColor.whiteColor;
    }

    return _mainView;
}

- (UIButton *)pluginsButton {
    if (!_pluginsButton) {
        _pluginsButton = [GrowingTKModuleButton moduleButtonWithType:GrowingTKModulePlugins];
        _pluginsButton.frame = CGRectMake(GrowingTKScreenWidth - _pluginsButton.growingtk_width * 2 - 25,
                                          IPHONE_STATUSBAR_HEIGHT + 5,
                                          _pluginsButton.growingtk_width,
                                          _pluginsButton.growingtk_width);
        [_pluginsButton addTarget:self action:@selector(showPluginsList) forControlEvents:UIControlEventTouchUpInside];
    }

    return _pluginsButton;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [GrowingTKModuleButton moduleButtonWithType:GrowingTKModuleCheckSelf];
        _checkButton.frame = CGRectMake(GrowingTKScreenWidth - _checkButton.growingtk_width - 10,
                                        IPHONE_STATUSBAR_HEIGHT + 5,
                                        _checkButton.growingtk_width,
                                        _checkButton.growingtk_width);
        [_checkButton addTarget:self action:@selector(showCheckSelf) forControlEvents:UIControlEventTouchUpInside];
    }

    return _checkButton;
}

- (UIImageView *)triangleView {
    if (!_triangleView) {
        CGFloat triangleHeight = 30.f;
        _triangleView = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, MAIN_VIEW_TOP - triangleHeight + 10, triangleHeight, triangleHeight)];
        _triangleView.tintColor = UIColor.blackColor;
        if (@available(iOS 13.0, *)) {
            _triangleView.image =
                UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
                    ? [UIImage growingtk_imageNamed:@"growingtk_triangle_black"]
                    : [UIImage growingtk_imageNamed:@"growingtk_triangle"];
        } else {
            _triangleView.image = [UIImage growingtk_imageNamed:@"growingtk_triangle"];
        }
    }

    return _triangleView;
}

- (GrowingTKPluginsListViewController *)pluginsList {
    if (!_pluginsList) {
        _pluginsList = [[GrowingTKPluginsListViewController alloc] init];
    }

    return _pluginsList;
}

- (GrowingTKSDKCheckViewController *)checkSelf {
    if (!_checkSelf) {
        _checkSelf = [[GrowingTKSDKCheckViewController alloc] init];
    }

    return _checkSelf;
}

@end
