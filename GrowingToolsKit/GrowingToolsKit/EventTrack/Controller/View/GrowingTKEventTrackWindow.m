//
//  GrowingTKEventTrackWindow.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/25.
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

#import "GrowingTKEventTrackWindow.h"
#import "GrowingTKEventTrackViewController.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@implementation GrowingTKEventTrackWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    self.windowScene = windowScene;
                    break;
                }
            }
        }
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = GrowingTKSizeFrom750(8);
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor growingtk_colorWithHex:@"0x999999" alpha:0.2].CGColor;
        self.windowLevel = UIWindowLevelAlert;
        self.rootViewController = [[GrowingTKEventTrackViewController alloc] init];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

#pragma mark - Action

- (void)pan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;

    if (!panView.hidden) {
        CGPoint offsetPoint = [sender translationInView:sender.view];
        [sender setTranslation:CGPointZero inView:sender.view];
        CGFloat newX = panView.growingtk_centerX + offsetPoint.x;
        CGFloat newY = panView.growingtk_centerY + offsetPoint.y;
        CGPoint centerPoint = CGPointMake(newX, newY);
        panView.center = centerPoint;
    }
}

@end
