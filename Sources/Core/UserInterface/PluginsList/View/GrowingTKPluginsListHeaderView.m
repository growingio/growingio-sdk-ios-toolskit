//
//  GrowingTKHomeHeaderView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
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

#import "GrowingTKPluginsListHeaderView.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKPluginsListHeaderView ()

@property (nonatomic, strong) UILabel *title;

@end

@implementation GrowingTKPluginsListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.growingtk_white_1;
        self.title = [UILabel new];
        [self addSubview:self.title];
    }
    return self;
}

- (void)renderUIWithTitle:(NSString *)title {
    _title.text = title;
    _title.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.title sizeToFit];
    self.title.frame = CGRectMake(GrowingTKSizeFrom750(32),
                                  self.growingtk_height / 2 - self.title.growingtk_height / 2,
                                  self.title.growingtk_width,
                                  self.title.growingtk_height);
}

@end
