//
//  GrowingTKNetFlowTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/8.
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

#import "GrowingTKNetFlowTableViewCell.h"
#import "GrowingTKRequestPersistence.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKNetFlowTableViewCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *statusCodeLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *urlStringLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *durationBgView;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *uploadFlowLabel;

@end

@implementation GrowingTKNetFlowTableViewCell

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

        self.statusCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusCodeLabel.textColor = UIColor.growingtk_tertiaryBackgroundColor;
        self.statusCodeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
        self.statusCodeLabel.textAlignment = NSTextAlignmentCenter;
        self.statusCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.statusCodeLabel];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusLabel.textColor = UIColor.growingtk_black_2;
        self.statusLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.numberOfLines = 2;
        self.statusLabel.adjustsFontSizeToFitWidth = YES;
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.statusLabel];

        self.urlStringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.urlStringLabel.textColor = UIColor.growingtk_black_2;
        self.urlStringLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        self.urlStringLabel.numberOfLines = 2;
        self.urlStringLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.urlStringLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.urlStringLabel];

        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.textColor = UIColor.growingtk_black_1;
        self.timeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timeLabel];

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

        self.methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.methodLabel.textColor = UIColor.growingtk_secondaryBackgroundColor;
        self.methodLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.methodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.methodLabel];

        self.uploadFlowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.uploadFlowLabel.textColor = UIColor.growingtk_black_1;
        self.uploadFlowLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.uploadFlowLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.uploadFlowLabel];

        CGFloat margin = 3.0f;
        [NSLayoutConstraint activateConstraints:@[
            [self.bgView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0f],
            [self.bgView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8.0f],
            [self.bgView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:2.0f],
            [self.bgView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-2.0f],

            [self.statusCodeLabel.leadingAnchor constraintEqualToAnchor:self.bgView.leadingAnchor],
            [self.statusCodeLabel.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(160)],
            [self.statusCodeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.statusLabel.widthAnchor constraintEqualToAnchor:self.statusCodeLabel.widthAnchor],
            [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.statusCodeLabel.centerXAnchor],
            [self.statusLabel.topAnchor constraintEqualToAnchor:self.statusCodeLabel.bottomAnchor],

            [self.urlStringLabel.topAnchor constraintEqualToAnchor:self.bgView.topAnchor constant:margin],
            [self.urlStringLabel.leadingAnchor constraintEqualToAnchor:self.statusCodeLabel.trailingAnchor],
            [self.urlStringLabel.trailingAnchor constraintEqualToAnchor:self.bgView.trailingAnchor constant:-margin],

            [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.urlStringLabel.leadingAnchor],
            [self.timeLabel.topAnchor constraintEqualToAnchor:self.urlStringLabel.bottomAnchor constant:margin],
            [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.timeLabel.trailingAnchor constant:10.0f],
            [self.durationLabel.centerYAnchor constraintEqualToAnchor:self.timeLabel.centerYAnchor],
            [self.durationBgView.centerXAnchor constraintEqualToAnchor:self.durationLabel.centerXAnchor],
            [self.durationBgView.centerYAnchor constraintEqualToAnchor:self.durationLabel.centerYAnchor],
            [self.durationBgView.widthAnchor constraintEqualToAnchor:self.durationLabel.widthAnchor constant:4.0f],
            [self.durationBgView.heightAnchor constraintEqualToAnchor:self.durationLabel.heightAnchor constant:4.0f],

            [self.methodLabel.topAnchor constraintEqualToAnchor:self.durationLabel.bottomAnchor constant:margin],
            [self.methodLabel.leadingAnchor constraintEqualToAnchor:self.urlStringLabel.leadingAnchor],
            [self.methodLabel.bottomAnchor constraintEqualToAnchor:self.bgView.bottomAnchor constant:-margin],
            [self.uploadFlowLabel.leadingAnchor constraintEqualToAnchor:self.methodLabel.trailingAnchor constant:10.0f],
            [self.uploadFlowLabel.centerYAnchor constraintEqualToAnchor:self.methodLabel.centerYAnchor]
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showRequest:(GrowingTKRequestPersistence *)request {
    self.statusCodeLabel.text = request.statusCode;
    self.statusCodeLabel.textColor = (request.statusCode.intValue >= 200 && request.statusCode.intValue < 300)
                                         ? UIColor.systemGreenColor
                                         : UIColor.growingtk_tertiaryBackgroundColor;
    self.statusLabel.text = request.status;
    self.urlStringLabel.text = request.url;
    self.timeLabel.text = request.startTime;
    self.durationLabel.text = [NSString stringWithFormat:@"%@：%.f%@",
                                                         GrowingTKLocalizedString(@"耗时"),
                                                         request.totalDuration.doubleValue * 1000,
                                                         GrowingTKLocalizedString(@"毫秒")];
    self.methodLabel.text = request.method;

    double mb = 1024.0 * 1024.0;
    double kb = 1024.0;
    double uploadFlow = request.uploadFlow.doubleValue;
    if (uploadFlow > mb) {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"↑%.2f MB", uploadFlow / mb];
    } else if (uploadFlow > kb) {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"↑%.2f KB", uploadFlow / kb];
    } else {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"↑%.2f bytes", uploadFlow];
    }
}

@end
