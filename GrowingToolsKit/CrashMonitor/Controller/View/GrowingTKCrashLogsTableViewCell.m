//
//  GrowingTKCrashLogsTableViewCell.m
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

#import "GrowingTKCrashLogsTableViewCell.h"
#import "GrowingTKCrashLogsPersistence.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKCrashLogsTableViewCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *exceptionNameLabel;
@property (nonatomic, strong) UILabel *reasonLabel;

@property (nonatomic, strong) NSLayoutConstraint *exceptionNameLabelBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *exceptionNameLabelCenterYConstraint;

@end

@implementation GrowingTKCrashLogsTableViewCell

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
        
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.typeLabel.textColor = UIColor.growingtk_white_1;
        self.typeLabel.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        self.typeLabel.layer.cornerRadius = 4.0f;
        self.typeLabel.layer.masksToBounds = YES;
        self.typeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(20)];
        self.typeLabel.textAlignment = NSTextAlignmentCenter;
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.typeLabel.text = @"CRASH";
        [self.contentView addSubview:self.typeLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.textColor = UIColor.growingtk_black_1;
        self.timeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timeLabel];

        self.exceptionNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.exceptionNameLabel.textColor = UIColor.growingtk_black_1;
        self.exceptionNameLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.exceptionNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.exceptionNameLabel];

        self.reasonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.reasonLabel.textColor = UIColor.growingtk_black_2;
        self.reasonLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.reasonLabel.numberOfLines = 0;
        self.reasonLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(18)];
        self.reasonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.reasonLabel];

        self.exceptionNameLabelBottomConstraint = [self.exceptionNameLabel.bottomAnchor constraintEqualToAnchor:self.reasonLabel.topAnchor
                                                                                                       constant:-GrowingTKSizeFrom750(10)];
        self.exceptionNameLabelCenterYConstraint = [self.exceptionNameLabel.centerYAnchor constraintEqualToAnchor:self.bgView.centerYAnchor];

        CGFloat margin = GrowingTKSizeFrom750(6);
        [NSLayoutConstraint activateConstraints:@[
            [self.bgView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:GrowingTKSizeFrom750(16)],
            [self.bgView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-GrowingTKSizeFrom750(16)],
            [self.bgView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:GrowingTKSizeFrom750(4)],
            [self.bgView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-GrowingTKSizeFrom750(4)],
            [self.bgView.heightAnchor constraintGreaterThanOrEqualToConstant:GrowingTKSizeFrom750(100)],
            
            [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.bgView.leadingAnchor constant:margin],
            [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.exceptionNameLabel.leadingAnchor constant:-margin],
            [self.timeLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(125)],
            [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.bgView.centerYAnchor constant:-GrowingTKSizeFrom750(14)],
            
            [self.typeLabel.centerXAnchor constraintEqualToAnchor:self.timeLabel.centerXAnchor],
            [self.typeLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(80)],
            [self.typeLabel.topAnchor constraintEqualToAnchor:self.timeLabel.bottomAnchor constant:GrowingTKSizeFrom750(6)],
            
            [self.exceptionNameLabel.trailingAnchor constraintEqualToAnchor:self.bgView.trailingAnchor constant:-margin],
            [self.exceptionNameLabel.topAnchor constraintEqualToAnchor:self.bgView.topAnchor constant:GrowingTKSizeFrom750(10)],
            self.exceptionNameLabelBottomConstraint,
            
            [self.reasonLabel.leadingAnchor constraintEqualToAnchor:self.exceptionNameLabel.leadingAnchor],
            [self.reasonLabel.widthAnchor constraintEqualToAnchor:self.exceptionNameLabel.widthAnchor],
            [self.reasonLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bgView.bottomAnchor constant:-GrowingTKSizeFrom750(10)],
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showCrashLog:(GrowingTKCrashLogsPersistence *)crashLog {
    self.timeLabel.text = crashLog.time;
    self.exceptionNameLabel.text = [NSString stringWithFormat:@"%@(%@)", crashLog.machException, crashLog.signal];
    self.reasonLabel.text = crashLog.reason;
    self.exceptionNameLabelBottomConstraint.active = crashLog.reason.length > 0;
    self.exceptionNameLabelCenterYConstraint.active = crashLog.reason.length <= 0;
}

@end
