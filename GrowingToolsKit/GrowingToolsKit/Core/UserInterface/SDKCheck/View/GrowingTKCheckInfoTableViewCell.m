//
//  GrowingTKCheckInfoTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/9.
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

#import "GrowingTKCheckInfoTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKCheckInfoTableViewCell ()

// check
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UILabel *checkLabel;

// info
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation GrowingTKCheckInfoTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.textColor = UIColor.growingtk_secondaryLabelColor;
        self.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.titleLabel];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.numberOfLines = 0;
        self.valueLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
        self.valueLabel.textColor = UIColor.growingtk_labelColor;
        self.valueLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.valueLabel];

        self.circleView = [[UIView alloc] initWithFrame:CGRectZero];
        self.circleView.backgroundColor = UIColor.growingtk_tertiaryBackgroundColor;
        self.circleView.layer.cornerRadius = 3.0f;
        self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.circleView];
        
        self.checkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.checkLabel.textAlignment = NSTextAlignmentCenter;
        self.checkLabel.textColor = UIColor.growingtk_tertiaryBackgroundColor;
        self.checkLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(30)];
        self.checkLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.checkLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:4.0],
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
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:0.3
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.titleLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:20.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:4.0],
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
                                          constant:-4.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.titleLabel
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:20.0],
            [NSLayoutConstraint constraintWithItem:self.valueLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:20.0],
            [NSLayoutConstraint constraintWithItem:self.checkLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:4.0],
            [NSLayoutConstraint constraintWithItem:self.checkLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:20.0],
            [NSLayoutConstraint constraintWithItem:self.checkLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:0.6
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.circleView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:6.0],
            [NSLayoutConstraint constraintWithItem:self.circleView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:6.0],
            [NSLayoutConstraint constraintWithItem:self.circleView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.contentView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.circleView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.checkLabel
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:-8.0]
        ]];
    }
    return self;
}

#pragma mark - Public Method

- (void)showCheck:(NSString *)checkMessage {
    self.checkLabel.hidden = NO;
    self.circleView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.valueLabel.hidden = YES;

    self.checkLabel.text = checkMessage;
}

- (void)showInfo:(NSString *)title message:(NSString *)infoMessage {
    self.checkLabel.hidden = YES;
    self.circleView.hidden = YES;
    self.titleLabel.hidden = NO;
    self.valueLabel.hidden = NO;
    
    self.titleLabel.text = title;
    self.valueLabel.text = infoMessage;
}

@end
