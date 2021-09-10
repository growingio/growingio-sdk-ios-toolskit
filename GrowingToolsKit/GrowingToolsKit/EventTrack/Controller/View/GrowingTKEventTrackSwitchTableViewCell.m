//
//  GrowingTKEventTrackSwitchTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/24.
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

#import "GrowingTKEventTrackSwitchTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "GrowingTKEventTrackPlugin.h"

@interface GrowingTKEventTrackSwitchTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *statusSwitch;
@property (nonatomic, strong) UIImageView *rightArrowImageView;

@end

@implementation GrowingTKEventTrackSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textColor = [UIColor growingtk_black_1];
        self.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];
        
        self.statusSwitch = [[UISwitch alloc] init];
        self.statusSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [self.statusSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.statusSwitch];
        
        self.rightArrowImageView = [[UIImageView alloc] init];
        self.rightArrowImageView.image = [UIImage growingtk_imageNamed:@"growingtk_right_arrow_gray"];
        self.rightArrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.rightArrowImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:16.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:150.0],
            [NSLayoutConstraint constraintWithItem:self.statusSwitch
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.statusSwitch
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-16.0],
            [NSLayoutConstraint constraintWithItem:self.rightArrowImageView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.rightArrowImageView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-16.0]
        ]];
    }
    
    return self;
}

- (void)renderUIWithIndex:(NSUInteger)index {
    switch (index) {
        case 0: {
            self.titleLabel.text = GrowingTKLocalizedString(@"开关");
            self.statusSwitch.hidden = NO;
            self.statusSwitch.on = GrowingTKEventTrackPlugin.plugin.isEventTrack;
            self.rightArrowImageView.hidden = YES;
        }
            break;
        case 1: {
            self.titleLabel.text = GrowingTKLocalizedString(@"查看记录");
            self.statusSwitch.hidden = YES;
            self.rightArrowImageView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)switchChange:(UISwitch *)sender {
    GrowingTKEventTrackPlugin.plugin.eventTrack = sender.isOn;
}

@end
