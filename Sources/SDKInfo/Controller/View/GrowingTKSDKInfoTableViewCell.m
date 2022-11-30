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
@property (nonatomic, strong) NSLayoutConstraint *titleLabelWidthConstraint;

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

        self.titleLabelWidthConstraint = [self.titleLabel.widthAnchor constraintGreaterThanOrEqualToConstant:100.0f];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0f],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0f],
            self.titleLabelWidthConstraint,
            [self.titleLabel.heightAnchor constraintGreaterThanOrEqualToConstant:24.0f],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0f],
            [self.valueLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0f],
            [self.valueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0f],
            [self.valueLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0f],
            [self.valueLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:10.0f],
            [self.valueLabel.heightAnchor constraintGreaterThanOrEqualToConstant:24.0f]
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
    
    CGFloat width = [self.valueLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 36.0f)].width;
    if (width < (GrowingTKScreenWidth - 200.0f - 42.0f)) {
        self.titleLabelWidthConstraint.constant = 200.0f;
    } else {
        self.titleLabelWidthConstraint.constant = 100.0f;
    }
    [self setNeedsUpdateConstraints];
}

@end

