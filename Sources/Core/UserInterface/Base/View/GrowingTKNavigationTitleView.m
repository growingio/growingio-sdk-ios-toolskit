//
//  GrowingTKNavigationTitleView.m
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

#import "GrowingTKNavigationTitleView.h"
#import "GrowingTKChooseView.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

typedef void (^GrowingTKNavigationTitleViewSingleTapBlock)(void);
typedef void (^GrowingTKNavigationTitleViewLongPressBlock)(NSUInteger index);

@interface GrowingTKNavigationTitleView ()

@property (nonatomic, copy) GrowingTKNavigationTitleViewSingleTapBlock singleTapBlock;
@property (nonatomic, copy) GrowingTKNavigationTitleViewLongPressBlock longPressBlock;
@property (nonatomic, copy) NSArray <NSString *>*components;
@property (nonatomic, strong) GrowingTKChooseView *chooseView;

@end

@implementation GrowingTKNavigationTitleView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                   components:(NSArray <NSString *> *)components
              singleTapAction:(void (^)(void))singleTapAction
              longPressAction:(void (^)(NSUInteger))longPressAction {
    if (self = [super initWithFrame:frame]) {
        self.components = components;
        self.singleTapBlock = singleTapAction;
        self.longPressBlock = longPressAction;
        
        self.userInteractionEnabled = YES;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   frame.size.width,
                                                                   frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textColor = UIColor.growingtk_labelColor;
        label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(34) weight:UIFontWeightMedium];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.7;
        label.text = title;
        [self addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(singleTapAction)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
        [longPress addTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

#pragma mark - Public Method

- (void)reset {
    if (self.chooseView && self.chooseView.superview) {
        [self.chooseView removeFromSuperview];
        self.chooseView = nil;
    }
}

#pragma mark - Action

- (void)singleTapAction {
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    CGPoint point = CGPointMake(self.growingtk_centerX - GrowingTKSizeFrom750(100),
                                self.growingtk_bottom + GrowingTKSizeFrom750(20));
    point = [self convertPoint:point toView:self.window];
    self.chooseView = [[GrowingTKChooseView alloc] initWithPoint:point
                                                         options:self.components
                                                  chooseCallback:^(NSUInteger index) {
        if (weakSelf.longPressBlock) {
            weakSelf.longPressBlock(index);
        }
        
        [weakSelf.chooseView removeFromSuperview];
        weakSelf.chooseView = nil;
    }];

    [self.growingtk_viewController.view addSubview:self.chooseView];
}

@end
