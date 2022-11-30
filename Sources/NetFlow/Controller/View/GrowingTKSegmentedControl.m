//
//  GrowingTKSegmentedControl.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/9.
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

#import "GrowingTKSegmentedControl.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKSegmentedControl ()

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, copy) GrowingTKSegmentedControlSelectedBlock block;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) NSLayoutConstraint *bottomLineCenterXConstraint;

@end

@implementation GrowingTKSegmentedControl

#pragma mark - Init

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles
                 selectedBlock:(GrowingTKSegmentedControlSelectedBlock)block {
    if (self = [super init]) {
        self.backgroundColor = UIColor.clearColor;
        for (int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.tag = i;
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
            [button setTitleColor:UIColor.growingtk_black_2 forState:UIControlStateNormal];
            [button setTitleColor:UIColor.growingtk_primaryBackgroundColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.buttons addObject:button];
        }

        self.bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomLine.backgroundColor = UIColor.growingtk_primaryBackgroundColor;
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bottomLine];

        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stackView];
        for (UIButton *button in self.buttons) {
            [stackView addArrangedSubview:button];
        }
        [NSLayoutConstraint activateConstraints:@[
            [self.bottomLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.bottomLine.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(50)],
            [self.bottomLine.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(4)],
            [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];

        self.block = block;
        [self setSelectedButton:0];
    }
    return self;
}

#pragma mark - Private Method

- (void)setSelectedButton:(NSInteger)index {
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        button.selected = button.tag == index;
    }

    if (self.bottomLineCenterXConstraint) {
        self.bottomLineCenterXConstraint.active = NO;
    }
    self.bottomLineCenterXConstraint =
        [self.bottomLine.centerXAnchor constraintEqualToAnchor:((UIButton *)self.buttons[index]).centerXAnchor];
    self.bottomLineCenterXConstraint.active = YES;
    [self.bottomLine setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self layoutIfNeeded];
                     }
                     completion:nil];
}

#pragma mark - Action

- (void)selectedAction:(UIButton *)sender {
    [self setSelectedButton:sender.tag];

    if (self.block) {
        self.block(sender.tag, sender.titleLabel.text);
    }
}

#pragma mark - Getter & Setter

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
