//
//  GrowingTKNetFlowDetailTableViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/9.
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

#import "GrowingTKNetFlowDetailTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKNetFlowDetailTableViewCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) NSArray <NSLayoutConstraint *>*labelConstraints;
@property (nonatomic, copy) NSArray <NSLayoutConstraint *>*textViewConstraints;

@end

@implementation GrowingTKNetFlowDetailTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textColor = UIColor.growingtk_black_1;
        self.label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.label.numberOfLines = 0;
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.label];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.textView.textColor = UIColor.growingtk_black_1;
        self.textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.textView.editable = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.textView];
        
        self.labelConstraints = @[
            [self.label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0f],
            [self.label.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8.0f],
            [self.label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0f],
            [self.label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0f]
        ];
        
        self.textViewConstraints = @[
            [self.textView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0f],
            [self.textView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8.0f],
            [self.textView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.0f],
            [self.textView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0.0f],
            [self.textView.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(800)]
        ];
        
        [NSLayoutConstraint activateConstraints:self.labelConstraints];
    }
    return self;
}

#pragma mark - Public Method

- (void)showText:(NSString *)text {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0f;
    style.lineBreakMode = NSLineBreakByCharWrapping;

    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSForegroundColorAttributeName: UIColor.growingtk_black_1,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)],
        NSParagraphStyleAttributeName: style
    };
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    if (text.length > 100000) {
        [NSLayoutConstraint deactivateConstraints:self.labelConstraints];
        self.label.hidden = YES;
        [NSLayoutConstraint activateConstraints:self.textViewConstraints];
        self.textView.hidden = NO;
        self.textView.attributedText = string;
    } else {
        [NSLayoutConstraint deactivateConstraints:self.textViewConstraints];
        self.textView.hidden = YES;
        [NSLayoutConstraint activateConstraints:self.labelConstraints];
        self.label.hidden = NO;
        self.label.attributedText = string;
    }
}

- (void)clearText {
    self.label.attributedText = nil;
    self.textView.attributedText = nil;
}

@end
