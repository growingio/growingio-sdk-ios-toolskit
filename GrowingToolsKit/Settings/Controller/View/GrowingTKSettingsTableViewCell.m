//
//  GrowingTKSettingsTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/16.
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

#import "GrowingTKSettingsTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKSettingsTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *leftImageView;

@end

@implementation GrowingTKSettingsTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.growingtk_white_1;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textColor = UIColor.growingtk_black_1;
        self.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailLabel.textColor = UIColor.growingtk_black_2;
        self.detailLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(26)];
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
        self.detailLabel.adjustsFontSizeToFitWidth = YES;
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.detailLabel];

        self.leftImageView = [[UIImageView alloc] init];
        self.leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.leftImageView];

        [NSLayoutConstraint activateConstraints:@[
            [self.leftImageView.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(65)],
            [self.leftImageView.heightAnchor constraintEqualToAnchor:self.leftImageView.widthAnchor],
            [self.leftImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.leftImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:GrowingTKSizeFrom750(32)],
            
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leftImageView.trailingAnchor constant:GrowingTKSizeFrom750(32)],
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:GrowingTKSizeFrom750(20)],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-GrowingTKSizeFrom750(20)],
            
            [self.detailLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
            [self.detailLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:GrowingTKSizeFrom750(10)],
            [self.detailLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-GrowingTKSizeFrom750(20)],
            [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-GrowingTKSizeFrom750(20)]
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail image:(UIImage *)image {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    self.leftImageView.image = image;
}

@end
