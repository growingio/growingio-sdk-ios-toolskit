//
//  GrowingTKEventDetailViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/13.
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

#import "GrowingTKEventDetailViewController.h"
#import "UIViewController+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKEventDetailViewController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation GrowingTKEventDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.textView];

    CGFloat margin = 12.0f;
    CGFloat closeButtonSideLength = 30.0f;
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.topAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.topAnchor
                                                   constant:margin],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.trailingAnchor
                                                        constant:-margin],
        [self.closeButton.widthAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.closeButton.heightAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.textView.topAnchor constraintEqualToAnchor:self.closeButton.bottomAnchor constant:margin],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.textView.text = self.beautifulJsonString;
}

#pragma mark - Private Method

- (NSString *)beautifulJsonString {
    NSString *beautifulJsonString = @"";
    if (self.rawJsonString.length == 0) {
        return beautifulJsonString;
    }

    NSData *jsonData = [self.rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
        return beautifulJsonString;
    }

    jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
        return beautifulJsonString;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSArray *lines = [jsonString componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        beautifulJsonString = [NSString stringWithFormat:@"%@ %@\n", beautifulJsonString, line];
    }
    return beautifulJsonString;
}

#pragma mark - Action

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        _textView.textColor = UIColor.growingtk_labelColor;
        _textView.editable = NO;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close_orange"]
                                forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
