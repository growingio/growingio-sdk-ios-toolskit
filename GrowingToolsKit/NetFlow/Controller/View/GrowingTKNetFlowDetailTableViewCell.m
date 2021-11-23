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
#import "GrowingTKCopyTextView.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKNetFlowDetailTableViewCell ()

@property (nonatomic, strong) GrowingTKCopyTextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation GrowingTKNetFlowDetailTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[GrowingTKCopyTextView alloc] initWithFrame:CGRectZero];
        self.textView.textColor = UIColor.growingtk_black_1;
        self.textView.backgroundColor = UIColor.clearColor;
        self.textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.textView.textContainerInset = UIEdgeInsetsZero;
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.bounces = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.textView];
        
        self.heightConstraint = [self.textView.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(1200)];

        [NSLayoutConstraint activateConstraints:@[
            self.heightConstraint,
            [self.textView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0f],
            [self.textView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8.0f],
            [self.textView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0f],
            [self.textView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0f],
        ]];
    }
    return self;
}

#pragma mark - Private Method

- (NSMutableAttributedString *)beautifulString:(NSString *)text {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0f;
    style.lineBreakMode = NSLineBreakByCharWrapping;

    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSForegroundColorAttributeName: UIColor.growingtk_black_1,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)],
        NSParagraphStyleAttributeName: style
    };
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    return string;
}

#pragma mark - Public Method

- (void)showText:(NSString *)text {
    self.textView.attributedText = [self beautifulString:text];
    CGFloat height = GrowingTKSizeFrom750(1200);
    if (text.length <= 50000) {
        height = [self.textView sizeThatFits:CGSizeMake(GrowingTKScreenWidth - 16, CGFLOAT_MAX)].height;
    }
    self.heightConstraint.constant = height;
    [self.textView setNeedsUpdateConstraints];
}

@end
