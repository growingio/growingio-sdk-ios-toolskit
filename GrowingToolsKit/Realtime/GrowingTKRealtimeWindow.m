//
//  GrowingTKRealtimeWindow.m
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

#import "GrowingTKRealtimeWindow.h"
#import "GrowingTKRealtimeViewController.h"

@implementation GrowingTKRealtimeWindow

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
        self.backgroundColor = UIColor.clearColor;
        self.windowLevel = UIWindowLevelAlert;
        self.rootViewController = [[GrowingTKRealtimeViewController alloc] init];
    }
    return self;
}

- (void)toggle {
    if (self.isHidden) {
        self.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeShouldHideNotification object:nil];
        [((GrowingTKRealtimeViewController *)self.rootViewController) start];
    } else {
        self.hidden = YES;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self || view == self.rootViewController.view) ? nil : view;
}

@end
