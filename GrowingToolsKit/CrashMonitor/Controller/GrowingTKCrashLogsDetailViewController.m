//
//  GrowingTKCrashLogsDetailViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/7.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTKCrashLogsDetailViewController.h"
#import "GrowingTKCopyTextView.h"
#import "GrowingTKCrashLogsPersistence.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKCrashLogsDetailViewController ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) GrowingTKCopyTextView *textView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation GrowingTKCrashLogsDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.typeLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.textView];

    CGFloat margin = 12.0f;
    CGFloat closeButtonSideLength = 30.0f;
    [NSLayoutConstraint activateConstraints:@[
        [self.typeLabel.centerYAnchor constraintEqualToAnchor:self.closeButton.centerYAnchor],
        [self.typeLabel.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor
                                                     constant:margin * 1.5],
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor
                                                   constant:margin],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor
                                                        constant:-margin],
        [self.closeButton.widthAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.closeButton.heightAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.textView.topAnchor constraintEqualToAnchor:self.closeButton.bottomAnchor constant:margin],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor
                                                    constant:margin],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)", self.crashLog.machException, self.crashLog.signal];
    self.textView.text = self.crashLog.appleFmt;
}

#pragma mark - Action

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(40) weight:UIFontWeightSemibold];
        _typeLabel.textColor = UIColor.growingtk_primaryBackgroundColor;
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _typeLabel;
}

- (GrowingTKCopyTextView *)textView {
    if (!_textView) {
        _textView = [[GrowingTKCopyTextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(22)];
        _textView.textColor = UIColor.growingtk_labelColor;
        _textView.backgroundColor = UIColor.clearColor;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close"]
                                forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
