//
//  GrowingTKCheckInfoTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/9.
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

#import "GrowingTKCheckInfoTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKCheckInfoTableViewCell ()

// check
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UILabel *checkLabel;

// info
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation GrowingTKCheckInfoTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.textColor = UIColor.growingtk_secondaryLabelColor;
        self.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.numberOfLines = 0;
        self.valueLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
        self.valueLabel.textColor = UIColor.growingtk_labelColor;
        self.valueLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.valueLabel];

        self.circleView = [[UIView alloc] initWithFrame:CGRectZero];
        self.circleView.backgroundColor = UIColor.growingtk_tertiaryBackgroundColor;
        self.circleView.layer.cornerRadius = 3.0f;
        self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.circleView];
        
        self.checkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.checkLabel.textAlignment = NSTextAlignmentCenter;
        self.checkLabel.textColor = UIColor.growingtk_tertiaryBackgroundColor;
        self.checkLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(30)];
        self.checkLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.checkLabel];
        
        CGFloat margin = 4.0f;
        CGFloat padding = 2.0f;
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:margin],
            [self.titleLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.32],
            [self.titleLabel.heightAnchor constraintEqualToConstant:20.0],
            [self.valueLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
            [self.valueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-margin],
            [self.valueLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding],
            [self.valueLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:20.0],
            [self.valueLabel.heightAnchor constraintGreaterThanOrEqualToConstant:20.0],
            [self.checkLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
            [self.checkLabel.heightAnchor constraintEqualToConstant:20.0],
            [self.circleView.widthAnchor constraintEqualToConstant:6.0],
            [self.circleView.heightAnchor constraintEqualToConstant:6.0],
            [self.circleView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.circleView.trailingAnchor constraintEqualToAnchor:self.checkLabel.leadingAnchor constant:-8.0],
            [NSLayoutConstraint constraintWithItem:self.checkLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:0.6
                                          constant:0.0]
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showCheck:(NSString *)checkMessage {
    self.checkLabel.hidden = NO;
    self.circleView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.valueLabel.hidden = YES;

    self.checkLabel.text = checkMessage;
}

- (void)showInfo:(NSString *)title message:(NSString *)infoMessage bad:(BOOL)isBad {
    self.checkLabel.hidden = YES;
    self.circleView.hidden = YES;
    self.titleLabel.hidden = NO;
    self.valueLabel.hidden = NO;
    
    self.titleLabel.text = title;
    self.valueLabel.text = infoMessage;
    self.valueLabel.textColor = isBad ? UIColor.growingtk_tertiaryBackgroundColor : UIColor.growingtk_labelColor;
}

@end
