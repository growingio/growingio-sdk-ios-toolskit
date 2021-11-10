//
//  GrowingTKSDKInfoTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/19.
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

#import "GrowingTKSDKInfoTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "GrowingTKPermission.h"

@interface GrowingTKSDKInfoTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation GrowingTKSDKInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.growingtk_white_1;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textColor = [UIColor growingtk_black_1];
        self.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.numberOfLines = 0;
        self.valueLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        self.valueLabel.textColor = [UIColor growingtk_black_2];
        self.valueLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.valueLabel];

        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:8.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:16.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:100.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:36.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-8.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:8.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-16.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:-8.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.titleLabel
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:10.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:36.0]
        ]];
    }
    return self;
}

- (void)renderUIWithData:(NSDictionary *)data {
    NSString *title = data[@"title"];
    NSString *value = data[@"value"];

    self.titleLabel.text = title;

    NSString *cnValue = nil;
    if ([value isKindOfClass:[NSNumber class]]) {
        switch (value.integerValue) {
            case GrowingTKAuthorizationStatusNotDetermined:
                cnValue = GrowingTKLocalizedString(@"用户没有选择");
                break;
            case GrowingTKAuthorizationStatusRestricted:
                cnValue = GrowingTKLocalizedString(@"受限制");
                break;
            case GrowingTKAuthorizationStatusDenied:
                cnValue = GrowingTKLocalizedString(@"用户没有授权");
                break;
            case GrowingTKAuthorizationStatusAuthorized:
                cnValue = GrowingTKLocalizedString(@"用户已经授权");
                break;
            case GrowingTKAuthorizationStatusAlways:
                cnValue = GrowingTKLocalizedString(@"始终");
                break;
            case GrowingTKAuthorizationStatusWhenInUse:
                cnValue = GrowingTKLocalizedString(@"使用App期间");
                break;
            case GrowingTKAuthorizationStatusDisabled:
                cnValue = GrowingTKLocalizedString(@"用户关闭服务");
                break;
            default:
                break;
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        cnValue = value;
    }
    self.valueLabel.text = cnValue;
}

@end

