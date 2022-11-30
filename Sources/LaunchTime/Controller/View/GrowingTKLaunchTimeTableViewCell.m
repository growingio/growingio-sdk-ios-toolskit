//
//  GrowingTKLaunchTimeTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/9.
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

#import "GrowingTKLaunchTimeTableViewCell.h"
#import "GrowingTKLaunchTimePersistence.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKLaunchTimeTableViewCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *typeBgView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIView *durationBgView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation GrowingTKLaunchTimeTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.growingtk_white_2;
        
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.layer.cornerRadius = 5.0f;
        self.bgView.backgroundColor = UIColor.growingtk_white_1;
        self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bgView];
        
        self.typeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.typeBgView.layer.cornerRadius = 3.0f;
        self.typeBgView.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        self.typeBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.typeBgView];

        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.typeLabel.textColor = UIColor.whiteColor;
        self.typeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(18) weight:UIFontWeightMedium];
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.typeLabel];
        
        self.durationBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.durationBgView.layer.cornerRadius = 3.0f;
        self.durationBgView.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        self.durationBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.durationBgView];

        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.durationLabel.textColor = UIColor.whiteColor;
        self.durationLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(18) weight:UIFontWeightMedium];
        self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.durationLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.textColor = UIColor.growingtk_black_1;
        self.timeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.numberOfLines = 2;
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timeLabel];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.textColor = UIColor.growingtk_black_1;
        self.nameLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.nameLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.bgView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:GrowingTKSizeFrom750(16)],
            [self.bgView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-GrowingTKSizeFrom750(16)],
            [self.bgView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:GrowingTKSizeFrom750(4)],
            [self.bgView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-GrowingTKSizeFrom750(4)],
            
            [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.bgView.leadingAnchor constant:GrowingTKSizeFrom750(16)],
            [self.nameLabel.topAnchor constraintEqualToAnchor:self.bgView.topAnchor constant:GrowingTKSizeFrom750(16)],
            
            [self.typeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor constant:GrowingTKSizeFrom750(4)],
            [self.typeLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:GrowingTKSizeFrom750(10)],
            [self.typeBgView.centerXAnchor constraintEqualToAnchor:self.typeLabel.centerXAnchor],
            [self.typeBgView.centerYAnchor constraintEqualToAnchor:self.typeLabel.centerYAnchor],
            [self.typeBgView.widthAnchor constraintEqualToAnchor:self.typeLabel.widthAnchor constant:GrowingTKSizeFrom750(8)],
            [self.typeBgView.heightAnchor constraintEqualToAnchor:self.typeLabel.heightAnchor constant:GrowingTKSizeFrom750(8)],
            [self.typeBgView.bottomAnchor constraintEqualToAnchor:self.bgView.bottomAnchor constant:-GrowingTKSizeFrom750(16)],

            [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.typeBgView.trailingAnchor constant:GrowingTKSizeFrom750(20)],
            [self.durationLabel.centerYAnchor constraintEqualToAnchor:self.typeLabel.centerYAnchor],
            [self.durationBgView.centerXAnchor constraintEqualToAnchor:self.durationLabel.centerXAnchor],
            [self.durationBgView.centerYAnchor constraintEqualToAnchor:self.durationLabel.centerYAnchor],
            [self.durationBgView.widthAnchor constraintEqualToAnchor:self.durationLabel.widthAnchor constant:GrowingTKSizeFrom750(8)],
            [self.durationBgView.heightAnchor constraintEqualToAnchor:self.durationLabel.heightAnchor constant:GrowingTKSizeFrom750(8)],
            
            [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:GrowingTKSizeFrom750(4)],
            [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.bgView.trailingAnchor constant:-GrowingTKSizeFrom750(16)],
            [self.timeLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(124)],
            [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.bgView.centerYAnchor]
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showLaunchTime:(GrowingTKLaunchTimePersistence *)record {
    self.nameLabel.text = record.page;
    self.durationLabel.text = [NSString stringWithFormat:@"%.fms", record.duration];
    self.timeLabel.text = [NSString stringWithFormat:@"%@\n%@", record.time, record.day];
    
    switch (record.type) {
        case GrowingTKLaunchTimeTypeAppLaunch:
            self.typeLabel.text = @"App Launch";
            break;
        case GrowingTKLaunchTimeTypeAppRestart:
            self.typeLabel.text = @"App Restart";
            break;
        case GrowingTKLaunchTimeTypePageLoad:
            self.typeLabel.text = @"Page Load";
            break;
    }
}

@end
