//
//  GrowingTKHomeWindow.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/12.
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

#import "GrowingTKHomeWindow.h"
#import "GrowingTKDefine.h"
#import "GrowingTKHomeViewController.h"
#import "GrowingTKNavigationController.h"

@interface GrowingTKHomeWindow ()

@property (nonatomic, strong) UINavigationController *nav;

@end

@implementation GrowingTKHomeWindow

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingTKHomeWindow *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKHomeWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.windowLevel = UIWindowLevelStatusBar - 1.f;
        self.backgroundColor = UIColor.clearColor;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    self.windowScene = windowScene;
                    break;
                }
            }
        }
        GrowingTKHomeViewController *controller = [[GrowingTKHomeViewController alloc] init];
        GrowingTKNavigationController *nav =
            [[GrowingTKNavigationController alloc] initWithRootViewController:controller];
        self.nav = nav;
        self.rootViewController = nav;
    }
    return self;
}

#pragma mark - Public Method

- (void)toggle {
    if (self.isHidden) {
        self.hidden = NO;
    }else {
        if (self.rootViewController.presentedViewController) {
            [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
        }
        if (self.nav.viewControllers.count > 1) {
            [self.nav popToRootViewControllerAnimated:NO];
        }
        
        self.hidden = YES;
    }
}

+ (void)openPlugin:(UIViewController *)controller {
    [[self sharedInstance] openPlugin:controller];
}

#pragma mark - Private Method

- (void)openPlugin:(UIViewController *)controller {
    [self.nav pushViewController:controller animated:YES];
}

@end
