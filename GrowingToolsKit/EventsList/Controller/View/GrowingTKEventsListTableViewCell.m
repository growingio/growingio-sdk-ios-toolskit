//
//  GrowingTKEventsListTableViewCell.m
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

#import "GrowingTKEventsListTableViewCell.h"
#import "GrowingTKEventPersistence.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKEventsListTableViewCell ()

@property (nonatomic, strong) UILabel *globalSequenceIdLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *pathLabel;
@property (nonatomic, strong) UILabel *sendStatusLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSLayoutConstraint *typeLabelBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *typeLabelCenterYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *pathLabelTopConstraint;

@end

@implementation GrowingTKEventsListTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.growingtk_white_1;

        self.globalSequenceIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.globalSequenceIdLabel.textColor = UIColor.growingtk_black_2;
        self.globalSequenceIdLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.globalSequenceIdLabel.textAlignment = NSTextAlignmentCenter;
        self.globalSequenceIdLabel.adjustsFontSizeToFitWidth = YES;
        self.globalSequenceIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.globalSequenceIdLabel];

        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.typeLabel.textColor = UIColor.growingtk_black_1;
        self.typeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.typeLabel];

        self.pathLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.pathLabel.textColor = UIColor.growingtk_black_2;
        self.pathLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        self.pathLabel.numberOfLines = 2;
        self.pathLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(20)];
        self.pathLabel.adjustsFontSizeToFitWidth = YES;
        self.pathLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.pathLabel];

        self.sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.sendStatusLabel.textColor = UIColor.growingtk_black_1;
        self.sendStatusLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.sendStatusLabel.textAlignment = NSTextAlignmentCenter;
        self.sendStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.sendStatusLabel];

        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.textColor = UIColor.growingtk_black_1;
        self.timeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timeLabel];

        self.typeLabelBottomConstraint =
            [self.typeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor];
        self.pathLabelTopConstraint = [self.pathLabel.topAnchor constraintEqualToAnchor:self.contentView.centerYAnchor];
        self.typeLabelCenterYConstraint =
            [self.typeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor];

        CGFloat margin = 3.0f;
        [NSLayoutConstraint activateConstraints:@[
            [self.globalSequenceIdLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor
                                                                     constant:margin],
            [self.globalSequenceIdLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(90)],
            [self.globalSequenceIdLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.typeLabel.leadingAnchor constraintEqualToAnchor:self.globalSequenceIdLabel.trailingAnchor
                                                         constant:margin],
            [self.pathLabel.leadingAnchor constraintEqualToAnchor:self.typeLabel.leadingAnchor],
            [self.pathLabel.widthAnchor constraintEqualToAnchor:self.typeLabel.widthAnchor],
            [self.sendStatusLabel.leadingAnchor constraintEqualToAnchor:self.typeLabel.trailingAnchor constant:margin],
            [self.sendStatusLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(110)],
            [self.sendStatusLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.sendStatusLabel.trailingAnchor constant:margin],
            [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-margin],
            [self.timeLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(125)],
            [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            self.typeLabelBottomConstraint,
            self.pathLabelTopConstraint
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showEvent:(GrowingTKEventPersistence *)event {
    self.globalSequenceIdLabel.text = [NSString stringWithFormat:@"%@", event.globalSequenceId];
    self.typeLabel.text = event.eventType;
    
    self.pathLabel.text = event.path;
    self.typeLabelBottomConstraint.active = event.path.length > 0;
    self.pathLabelTopConstraint.active = event.path.length > 0;
    self.typeLabelCenterYConstraint.active = event.path.length <= 0;

    self.sendStatusLabel.text = GrowingTKLocalizedString(event.isSend ? @"已发送" : @"未发送");
    self.sendStatusLabel.textColor =
        event.isSend ? UIColor.growingtk_labelColor : UIColor.growingtk_tertiaryBackgroundColor;

    self.timeLabel.text = event.time;
}

@end
