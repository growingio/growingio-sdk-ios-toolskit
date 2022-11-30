//
//  GrowingTKChooseView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/3.
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

#import "GrowingTKChooseView.h"
#import "GrowingTKDefine.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKChooseView ()

@property (nonatomic, copy) void(^chooseCallback)(NSUInteger);

@end

@implementation GrowingTKChooseView

- (instancetype)initWithPoint:(CGPoint)point
                      options:(NSArray <NSString *>*)options
               chooseCallback:(void(^)(NSUInteger))chooseCallback {
    if (self = [super init]) {
        CGFloat buttonWidth = GrowingTKSizeFrom750(200);
        CGFloat buttonHeight = GrowingTKSizeFrom750(70);
        self.frame = CGRectMake(point.x, point.y, buttonWidth, options.count * buttonHeight);
        self.backgroundColor = UIColor.growingtk_white_1;
        self.layer.cornerRadius = 5.0f;
        self.layer.shadowColor = UIColor.growingtk_black_3.CGColor;
        self.layer.shadowOffset = CGSizeMake(5, 5);
        self.layer.shadowOpacity = 0.6f;
        self.layer.shadowRadius = 4.0f;
        
        for (int i = 0; i < options.count; i++) {
            NSString *option = options[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, i * buttonHeight, buttonWidth, buttonHeight);
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:button.frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = option;
            label.textColor = UIColor.growingtk_black_1;
            label.numberOfLines = 2;
            label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
            [self addSubview:label];
        }
        
        for (int i = 1; i <= (options.count / 2); i++) {
            UIView *hLine = [[UIView alloc] initWithFrame:CGRectMake(0, i * buttonHeight, buttonWidth, 0.5)];
            hLine.backgroundColor = [UIColor growingtk_colorWithHex:@"E2E2E2"];
            [self addSubview:hLine];
        }
        
        self.chooseCallback = chooseCallback;
    }
    return self;
}

#pragma mark - Action

- (void)buttonAction:(UIButton *)button {
    if (self.chooseCallback) {
        self.chooseCallback(button.tag);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!(view == self || view.superview == self)) {
        // 自动隐藏
        [self removeFromSuperview];
    }
    return view;
}

@end
