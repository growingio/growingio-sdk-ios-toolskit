//
//  GrowingTKNavigationItemView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/17.
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

#import "GrowingTKNavigationItemView.h"
#import "GrowingTKDefine.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

typedef void (^GrowingTKNavigationItemViewClickBlock)(void);

@interface GrowingTKNavigationItemView ()

@property (nonatomic, copy) GrowingTKNavigationItemViewClickBlock clickBlock;

@end

@implementation GrowingTKNavigationItemView

#pragma mark - Public Method

- (instancetype)initBackButtonWithFrame:(CGRect)frame action:(void (^)(void))action {
    if (self = [super initWithFrame:frame]) {
        [self configLeftButtonSubViewsWithText:nil textColor:nil image:nil action:action];
    }
    return self;
}

- (instancetype)initBackButtonWithFrame:(CGRect)frame image:(UIImage *)image action:(void (^)(void))action {
    if (self = [super initWithFrame:frame]) {
        [self configLeftButtonSubViewsWithText:nil textColor:nil image:image action:action];
    }
    return self;
}

- (instancetype)initBackButtonWithFrame:(CGRect)frame
                                   text:(nullable NSString *)text
                              textColor:(nullable UIColor *)textColor
                                  image:(nullable UIImage *)image
                                 action:(void (^)(void))action {
    if (self = [super initWithFrame:frame]) {
        [self configLeftButtonSubViewsWithText:text textColor:textColor image:image action:action];
    }
    return self;
}

- (instancetype)initRightButtonWithFrame:(CGRect)frame
                                    text:(NSString *)text
                               textColor:(nullable UIColor *)textColor
                                  action:(void (^)(void))action {
    if (self = [super initWithFrame:frame]) {
        [self configRightButtonSubViewsWithText:text textColor:textColor action:action];
    }
    return self;
}

#pragma mark - Private Method

- (void)configLeftButtonSubViewsWithText:(nullable NSString *)text
                               textColor:(nullable UIColor *)textColor
                                   image:(nullable UIImage *)image
                                  action:(void (^)(void))action {
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
    backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (!image) {
        image = [UIImage growingtk_imageNamed:@"growingtk_icon_back"];
    }
    backImageView.image = image;
    backImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:backImageView];

    if (text && text.length > 0) {
        CGFloat leading = backImageView.frame.size.width + GrowingTKSizeFrom750(8);
        UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(leading,
                                                      0,
                                                      self.frame.size.width - leading,
                                                      self.frame.size.height)];
        label.textAlignment = NSTextAlignmentLeft;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textColor = textColor ?: UIColor.growingtk_labelColor;
        label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        label.text = text;
        [self addSubview:label];
    }

    self.clickBlock = action;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:button];
    [button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configRightButtonSubViewsWithText:(NSString *)text
                                textColor:(nullable UIColor *)textColor
                                   action:(void (^)(void))action {
    if (!text || (text && text.length == 0)) {
        return;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    label.textAlignment = NSTextAlignmentRight;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textColor = textColor ?: UIColor.growingtk_labelColor;
    label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
    label.text = text;
    [self addSubview:label];

    self.clickBlock = action;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:button];
    [button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action

- (void)clickAction {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
