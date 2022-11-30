//
//  GrowingTKRealtimeSingleBubble.m
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

#import "GrowingTKRealtimeSingleBubble.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKRealtimeEvent.h"

static CGFloat const DefaultBubbleHeight = 70.0f;

@interface GrowingTKRealtimeSingleBubble ()

@property (nonatomic, strong, readwrite) GrowingTKRealtimeEvent *event;
@property (nonatomic, strong) UILabel *eventTypeLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *gesidLabel;
@property (nonatomic, strong) UIView *whiteBackgroundView;
@property (nonatomic, strong) UIView *leftBackgroundView;

@property (nonatomic, strong) NSLayoutConstraint *eventTypeLabelTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *eventTypeLabelCenterYConstraint;

@end

@implementation GrowingTKRealtimeSingleBubble

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.4f;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        
        CGFloat height = GrowingTKSizeFrom750(DefaultBubbleHeight);
        CGFloat corner = height / 2.0f;
        self.leftBackgroundView = [[UIView alloc] init];
        self.leftBackgroundView.backgroundColor = UIColor.growingtk_primaryBackgroundColor;
        self.leftBackgroundView.layer.cornerRadius = corner;
        self.leftBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.leftBackgroundView];

        self.whiteBackgroundView = [[UIView alloc] init];
        self.whiteBackgroundView.backgroundColor = UIColor.growingtk_white_1;
        self.whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.whiteBackgroundView];
        
        self.eventTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.eventTypeLabel.textColor = UIColor.growingtk_black_1;
        self.eventTypeLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:GrowingTKSizeFrom750(26)];
        self.eventTypeLabel.textAlignment = NSTextAlignmentLeft;
        self.eventTypeLabel.numberOfLines = 1;
        self.eventTypeLabel.adjustsFontSizeToFitWidth = YES;
        self.eventTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.whiteBackgroundView addSubview:self.eventTypeLabel];

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailLabel.textColor = UIColor.growingtk_black_2;
        self.detailLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(20)];
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
        self.detailLabel.numberOfLines = 2;
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.whiteBackgroundView addSubview:self.detailLabel];
        
        self.gesidLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.gesidLabel.textColor = UIColor.growingtk_white_1;
        self.gesidLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:GrowingTKSizeFrom750(20)];
        self.gesidLabel.textAlignment = NSTextAlignmentCenter;
        self.gesidLabel.adjustsFontSizeToFitWidth = YES;
        self.gesidLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.leftBackgroundView addSubview:self.gesidLabel];
        
        self.eventTypeLabelTopConstraint = [self.eventTypeLabel.topAnchor constraintEqualToAnchor:self.whiteBackgroundView.topAnchor constant:GrowingTKSizeFrom750(4)];
        self.eventTypeLabelCenterYConstraint = [self.eventTypeLabel.centerYAnchor constraintEqualToAnchor:self.whiteBackgroundView.centerYAnchor];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.whiteBackgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.whiteBackgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.whiteBackgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

            [self.eventTypeLabel.leadingAnchor constraintEqualToAnchor:self.whiteBackgroundView.leadingAnchor constant:GrowingTKSizeFrom750(10)],
            [self.eventTypeLabel.trailingAnchor constraintEqualToAnchor:self.whiteBackgroundView.trailingAnchor constant:-GrowingTKSizeFrom750(10)],
            [self.eventTypeLabel.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(26)],
            self.eventTypeLabelTopConstraint,
            
            [self.detailLabel.leadingAnchor constraintEqualToAnchor:self.whiteBackgroundView.leadingAnchor constant:GrowingTKSizeFrom750(10)],
            [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.whiteBackgroundView.trailingAnchor constant:-GrowingTKSizeFrom750(10)],
            [self.detailLabel.topAnchor constraintEqualToAnchor:self.eventTypeLabel.bottomAnchor],
            [self.detailLabel.bottomAnchor constraintEqualToAnchor:self.whiteBackgroundView.bottomAnchor constant:-GrowingTKSizeFrom750(4)],
            [self.detailLabel.widthAnchor constraintLessThanOrEqualToConstant:GrowingTKSizeFrom750(280)],
            
            [self.leftBackgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.leftBackgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.leftBackgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.leftBackgroundView.trailingAnchor constraintEqualToAnchor:self.whiteBackgroundView.leadingAnchor constant:corner],
            [self.leftBackgroundView.widthAnchor constraintEqualToConstant:height * 1.6f],
            [self.leftBackgroundView.heightAnchor constraintGreaterThanOrEqualToConstant:height],
            
            [self.gesidLabel.leadingAnchor constraintEqualToAnchor:self.leftBackgroundView.leadingAnchor constant:corner - GrowingTKSizeFrom750(16)],
            [self.gesidLabel.trailingAnchor constraintEqualToAnchor:self.leftBackgroundView.trailingAnchor constant:-corner],
            [self.gesidLabel.topAnchor constraintEqualToAnchor:self.leftBackgroundView.topAnchor],
            [self.gesidLabel.bottomAnchor constraintEqualToAnchor:self.leftBackgroundView.bottomAnchor]
        ]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Public Method

- (void)configWithEvent:(GrowingTKRealtimeEvent *)event {
    self.event = event;
    self.gesidLabel.text = [NSString stringWithFormat:@"%@", event.globalSequenceId];
    self.eventTypeLabel.text = [NSString stringWithFormat:@"%@", event.eventType];
    self.detailLabel.text = [NSString stringWithFormat:@"%@", event.detail];
    
    self.eventTypeLabelTopConstraint.active = self.detailLabel.text.length != 0;
    self.eventTypeLabelCenterYConstraint.active = self.detailLabel.text.length == 0;
}

#pragma mark - Action

- (void)tapAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKShowEventsListNotification
                                                        object:nil
                                                      userInfo:@{@"window" : self.window, @"gesids" : @[self.event.globalSequenceId.copy]}];
}

@end
