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
    
    id view = self.view;
    if (@available(iOS 11.0, *)) {
        view = self.view.safeAreaLayoutGuide;
    }
    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.checkView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.checkView
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.checkView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:label2
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:label2
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:-30.0],
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:label2
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:-10.0]
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
