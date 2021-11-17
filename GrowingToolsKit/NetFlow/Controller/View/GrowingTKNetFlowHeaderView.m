//
//  GrowingTKNetFlowHeaderView.m
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

#import "GrowingTKNetFlowHeaderView.h"
#import "GrowingTKNetFlowPlugin.h"
#import "GrowingTKRequestPersistence.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKWeakObject.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKNetFlowHeaderView ()

@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *requestCountLabel;
@property (nonatomic, strong) UILabel *uploadFlowLabel;
@property (nonatomic, strong) UILabel *requestFailCountLabel;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GrowingTKNetFlowHeaderView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = UIColor.growingtk_white_1;
        view.layer.cornerRadius = 5.0f;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];

        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.durationLabel.text = @"0秒";
        self.durationLabel.textColor = UIColor.growingtk_black_1;
        self.durationLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.durationLabel];

        UILabel *durationDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        durationDescLabel.text = GrowingTKLocalizedString(@"已持续运行");
        durationDescLabel.textColor = UIColor.growingtk_black_2;
        durationDescLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(26)];
        durationDescLabel.textAlignment = NSTextAlignmentCenter;
        durationDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:durationDescLabel];

        self.requestCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.requestCountLabel.text = @"0";
        self.requestCountLabel.textColor = UIColor.growingtk_black_1;
        self.requestCountLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
        self.requestCountLabel.textAlignment = NSTextAlignmentCenter;
        self.requestCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.requestCountLabel];

        UILabel *requestCountDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        requestCountDescLabel.text = GrowingTKLocalizedString(@"请求数量");
        requestCountDescLabel.textColor = UIColor.growingtk_black_2;
        requestCountDescLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(26)];
        requestCountDescLabel.textAlignment = NSTextAlignmentCenter;
        requestCountDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:requestCountDescLabel];

        self.uploadFlowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.uploadFlowLabel.text = @"0B";
        self.uploadFlowLabel.textColor = UIColor.growingtk_black_1;
        self.uploadFlowLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
        self.uploadFlowLabel.textAlignment = NSTextAlignmentCenter;
        self.uploadFlowLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.uploadFlowLabel];

        UILabel *uploadFlowDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        uploadFlowDescLabel.text = GrowingTKLocalizedString(@"数据上传");
        uploadFlowDescLabel.textColor = UIColor.growingtk_black_2;
        uploadFlowDescLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(26)];
        uploadFlowDescLabel.textAlignment = NSTextAlignmentCenter;
        uploadFlowDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:uploadFlowDescLabel];

        self.requestFailCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.requestFailCountLabel.text = @"0";
        self.requestFailCountLabel.textColor = UIColor.growingtk_black_1;
        self.requestFailCountLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32) weight:UIFontWeightBold];
        self.requestFailCountLabel.textAlignment = NSTextAlignmentCenter;
        self.requestFailCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.requestFailCountLabel];

        UILabel *requestFailCountDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        requestFailCountDescLabel.text = GrowingTKLocalizedString(@"请求失败");
        requestFailCountDescLabel.textColor = UIColor.growingtk_black_2;
        requestFailCountDescLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(26)];
        requestFailCountDescLabel.textAlignment = NSTextAlignmentCenter;
        requestFailCountDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:requestFailCountDescLabel];

        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stackView];
        [stackView addArrangedSubview:self.requestCountLabel];
        [stackView addArrangedSubview:self.uploadFlowLabel];
        [stackView addArrangedSubview:self.requestFailCountLabel];

        UIStackView *stackView2 = [[UIStackView alloc] init];
        stackView2.axis = UILayoutConstraintAxisHorizontal;
        stackView2.distribution = UIStackViewDistributionFillEqually;
        stackView2.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stackView2];
        [stackView2 addArrangedSubview:requestCountDescLabel];
        [stackView2 addArrangedSubview:uploadFlowDescLabel];
        [stackView2 addArrangedSubview:requestFailCountDescLabel];

        CGFloat margin = 8.0f;
        [NSLayoutConstraint activateConstraints:@[
            [view.topAnchor constraintEqualToAnchor:self.topAnchor constant:margin / 2],
            [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-margin / 2],
            [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:margin],
            [view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-margin],
            [self.durationLabel.topAnchor constraintEqualToAnchor:view.topAnchor constant:15.0f],
            [self.durationLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
            [durationDescLabel.topAnchor constraintEqualToAnchor:self.durationLabel.bottomAnchor constant:5.0f],
            [durationDescLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
            [stackView.topAnchor constraintEqualToAnchor:durationDescLabel.bottomAnchor constant:20.0f],
            [stackView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
            [stackView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
            [stackView2.topAnchor constraintEqualToAnchor:stackView.bottomAnchor constant:5.0f],
            [stackView2.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
            [stackView2.trailingAnchor constraintEqualToAnchor:view.trailingAnchor]
        ]];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:[GrowingTKWeakObject weakObject:self]
                                                    selector:@selector(timerAction)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self timerAction];
    }
    return self;
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - Private Method

- (void)timerAction {
    NSTimeInterval duration =
        NSDate.date.timeIntervalSince1970 - GrowingTKNetFlowPlugin.plugin.pluginStartTimestamp / 1000LL;
    double day = 86400.0;
    double hour = 3600.0;
    double minute = 60.0;
    NSString *d = GrowingTKLocalizedString(@"天");
    NSString *h = GrowingTKLocalizedString(@"小时");
    NSString *m = GrowingTKLocalizedString(@"分");
    NSString *s = GrowingTKLocalizedString(@"秒");
    if (duration < minute) {
        self.durationLabel.text = [NSString stringWithFormat:@"%.f%@", duration, s];
    } else if (duration < hour) {
        self.durationLabel.text =
            [NSString stringWithFormat:@"%.f%@%.f%@", floor(duration / minute), m, fmod(duration, minute), s];
    } else if (duration < day) {
        self.durationLabel.text = [NSString stringWithFormat:@"%.f%@%.f%@%.f%@",
                                                             floor(duration / hour),
                                                             h,
                                                             floor(fmod(duration, hour) / minute),
                                                             m,
                                                             fmod(duration, minute),
                                                             s];
    } else {
        self.durationLabel.text = [NSString stringWithFormat:@"%.f%@%.f%@%.f%@%.f%@",
                                                             floor(duration / day),
                                                             d,
                                                             floor(fmod(duration, day) / hour),
                                                             h,
                                                             floor(fmod(duration, hour) / minute),
                                                             m,
                                                             fmod(duration, minute),
                                                             s];
    }

    NSUInteger requestCount = GrowingTKNetFlowPlugin.plugin.requestCount;
    double uploadFlow = GrowingTKNetFlowPlugin.plugin.totalUploadFlow;
    NSUInteger requestFailedCount = GrowingTKNetFlowPlugin.plugin.requestFailedCount;
    self.requestCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)requestCount];
    double mb = 1024.0 * 1024.0;
    double kb = 1024.0;
    if (uploadFlow > mb) {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"%.2f MB", uploadFlow / mb];
    } else if (uploadFlow > kb) {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"%.2f KB", uploadFlow / kb];
    } else {
        self.uploadFlowLabel.text = [NSString stringWithFormat:@"%.2f bytes", uploadFlow];
    }
    self.requestFailCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)requestFailedCount];
}

@end
