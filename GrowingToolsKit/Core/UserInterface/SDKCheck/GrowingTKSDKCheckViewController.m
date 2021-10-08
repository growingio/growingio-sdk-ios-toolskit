//
//  GrowingTKSDKCheckViewController.m
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

#import "GrowingTKSDKCheckViewController.h"
#import "GrowingTKCheckSelfView.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"
#import "UIViewController+GrowingTK.h"

@interface GrowingTKSDKCheckViewController ()

@property (nonatomic, strong) GrowingTKCheckSelfView *checkView;
@end

@implementation GrowingTKSDKCheckViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.checkView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"GOALS";
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    label.textColor = UIColor.growingtk_secondaryBackgroundColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];

    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"为用户提供最好的埋点服务";
    label2.font = [UIFont systemFontOfSize:10];
    label2.textColor = UIColor.growingtk_black_1;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label2];

    [NSLayoutConstraint activateConstraints:@[
        [self.checkView.centerXAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.centerXAnchor],
        [self.checkView.centerYAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.centerYAnchor constant:-30.0f],
        [self.checkView.widthAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.widthAnchor],
        [label2.centerXAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.centerXAnchor],
        [label2.bottomAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.bottomAnchor constant:-30.0f],
        [label.centerXAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.centerXAnchor],
        [label.bottomAnchor constraintEqualToAnchor:label2.topAnchor constant:-10.0f]
    ]];
}

#pragma mark - Getter & Setter

- (GrowingTKCheckSelfView *)checkView {
    if (!_checkView) {
        _checkView = [[GrowingTKCheckSelfView alloc] init];
    }
    return _checkView;
}

@end
