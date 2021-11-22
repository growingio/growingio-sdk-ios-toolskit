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

@interface GrowingTKHomeViewController ()

@property (nonatomic, assign) UIStatusBarStyle kStatusBarStyle;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) GrowingTKModuleButton *pluginsButton;
@property (nonatomic, strong) GrowingTKModuleButton *checkButton;
@property (nonatomic, strong) UIImageView *triangleView;
@property (nonatomic, strong) GrowingTKPluginsListViewController *pluginsList;
@property (nonatomic, strong) GrowingTKSDKCheckViewController *checkSelf;
@property (nonatomic, strong) UIViewController *currentChild;

@property (nonatomic, strong) NSLayoutConstraint *triangleViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *triangleViewCenterXConstraint2;

@end

@implementation GrowingTKHomeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideHome)
                                                 name:GrowingTKHomeShouldHideNotification
                                               object:nil];

    self.view.backgroundColor = UIColor.growingtk_black_alpha;
    [self.view addSubview:self.triangleView];
    [self.view addSubview:self.pluginsButton];
    [self.view addSubview:self.checkButton];
    [self.view addSubview:self.mainView];

    CGFloat mainViewTopMargin = GrowingTKSizeFrom750(160);
    CGFloat triangleHeight = 30.f;

    [NSLayoutConstraint activateConstraints:@[
        [self.mainView.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor
                                                constant:mainViewTopMargin],
        [self.mainView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.mainView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.checkButton.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor
                                                        constant:-10.0f],
        [self.checkButton.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor
                                                   constant:5.0f],
        [self.checkButton.heightAnchor constraintEqualToConstant:self.checkButton.growingtk_height],
        [self.checkButton.widthAnchor constraintEqualToConstant:self.checkButton.growingtk_width],
        [self.pluginsButton.trailingAnchor constraintEqualToAnchor:self.checkButton.leadingAnchor constant:-15.0f],
        [self.pluginsButton.centerYAnchor constraintEqualToAnchor:self.checkButton.centerYAnchor],
        [self.pluginsButton.heightAnchor constraintEqualToConstant:self.pluginsButton.growingtk_height],
        [self.pluginsButton.widthAnchor constraintEqualToConstant:self.pluginsButton.growingtk_width],
        [self.triangleView.bottomAnchor constraintEqualToAnchor:self.mainView.topAnchor constant:10.0f],
        [self.triangleView.heightAnchor constraintEqualToConstant:triangleHeight],
        [self.triangleView.widthAnchor constraintEqualToConstant:triangleHeight]
    ]];

    self.triangleViewCenterXConstraint =
        [self.triangleView.centerXAnchor constraintEqualToAnchor:self.pluginsButton.centerXAnchor];
    self.triangleViewCenterXConstraint2 =
        [self.triangleView.centerXAnchor constraintEqualToAnchor:self.checkButton.centerXAnchor];

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

    self.triangleViewCenterXConstraint2.active = NO;
    self.triangleViewCenterXConstraint.active = YES;
    [self.triangleView setNeedsUpdateConstraints];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
}

- (void)showCheckSelf {
    if (self.currentChild == self.checkSelf) {
        [[GrowingTKHomeWindow sharedInstance] toggle];
        [[GrowingTKEntryWindow sharedInstance] toggle:GrowingTKModuleCheckSelf];
        return;
    }
    [self showChildController:self.checkSelf];

    self.triangleViewCenterXConstraint.active = NO;
    self.triangleViewCenterXConstraint2.active = YES;
    [self.triangleView setNeedsUpdateConstraints];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
}

- (void)hideHome {
    [[GrowingTKHomeWindow sharedInstance] toggle];
    [[GrowingTKEntryWindow sharedInstance]
        toggle:self.currentChild == self.pluginsList ? GrowingTKModulePlugins : GrowingTKModuleCheckSelf];
}

#pragma mark - Override

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.kStatusBarStyle;
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
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _mainView;
}

- (UIButton *)pluginsButton {
    if (!_pluginsButton) {
        _pluginsButton = [GrowingTKModuleButton moduleButtonWithType:GrowingTKModulePlugins];
        _pluginsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_pluginsButton addTarget:self action:@selector(showPluginsList) forControlEvents:UIControlEventTouchUpInside];
    }

    return _pluginsButton;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [GrowingTKModuleButton moduleButtonWithType:GrowingTKModuleCheckSelf];
        _checkButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_checkButton addTarget:self action:@selector(showCheckSelf) forControlEvents:UIControlEventTouchUpInside];
    }

    return _checkButton;
}

- (UIImageView *)triangleView {
    if (!_triangleView) {
        _triangleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _triangleView.image = [UIImage growingtk_imageNamed:@"growingtk_triangle"];
        _triangleView.translatesAutoresizingMaskIntoConstraints = NO;
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
