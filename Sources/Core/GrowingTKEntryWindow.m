//
//  GrowingTKEntryWindow.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/11.
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

#import "GrowingTKEntryWindow.h"
#import "GrowingTKDefine.h"
#import "GrowingTKModuleButton.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKEntryViewController.h"
#import "GrowingTKHomeWindow.h"
#import "GrowingTKUtil.h"

@interface GrowingTKEntryWindow ()

@property (nonatomic, strong) GrowingTKModuleButton *entryButton;
@property (nonatomic, assign) CGPoint latestPosition;
@property (nonatomic, assign) GrowingTKModule moduleType;

@end

@implementation GrowingTKEntryWindow

static GrowingTKEntryWindow *instance = nil;

#pragma mark - Init

+ (instancetype)sharedInstance {
    if (!instance) {
        @throw [NSException
            exceptionWithName:@"GrowingToolsKit未初始化"
                       reason:@"请在applicationDidFinishLaunching中调用[GrowingToolsKit start], 并且确保在主线程中"
                     userInfo:nil];
    }
    return instance;
}

+ (void)startWithPoint:(CGPoint)startingPosition autoDock:(BOOL)autoDock {
    if (instance) {
        return;
    }

    CGFloat x = startingPosition.x;
    CGFloat y = startingPosition.y;
    CGPoint defaultPosition = GrowingTKStartingPosition;
    if (x < 0 || x > (GrowingTKScreenWidth - ENTRY_SIDELENGTH)) {
        x = defaultPosition.x;
    }

    if (y < 0 || y > (GrowingTKScreenHeight - ENTRY_SIDELENGTH)) {
        y = defaultPosition.y;
    }

    GrowingTKEntryWindow *window =
        [[GrowingTKEntryWindow alloc] initWithFrame:CGRectMake(x, y, ENTRY_SIDELENGTH, ENTRY_SIDELENGTH)];
    if (@available(iOS 13.0, *)) {
        UIScene *scene = [[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene) {
            window.windowScene = (UIWindowScene *)scene;
        }
    }
    window.backgroundColor = [UIColor clearColor];
    window.layer.masksToBounds = YES;

    window.rootViewController = [[GrowingTKEntryViewController alloc] init];
    [window.rootViewController.view addSubview:window.entryButton];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:window action:@selector(pan:)];
    [window addGestureRecognizer:pan];

    window.windowLevel = UIWindowLevelStatusBar - 1.f;
    window.hidden = NO;

    window->_autoDock = autoDock;
    window->_moduleType = GrowingTKModuleCheckSelf;
    instance = window;

    [[NSNotificationCenter defaultCenter] addObserver:window
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

#pragma mark - Action

- (void)toggle:(GrowingTKModule)moduleType {
    [self toggle:moduleType completion:nil];
}

- (void)toggle:(GrowingTKModule)moduleType completion:(void (^__nullable)(BOOL finished))completion {
    if (self.isHidden) {
        self.moduleType = moduleType;
        self.hidden = NO;

        [UIView animateWithDuration:0.3f
                              delay:0.0f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.growingtk_origin = self.latestPosition;
                         }
                         completion:completion];
    } else {
        self.latestPosition = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        [UIView animateWithDuration:0.3f
            delay:0.0f
            usingSpringWithDamping:0.7f
            initialSpringVelocity:0.0f
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                CGPoint endPoint = moduleType == GrowingTKModulePlugins ? self.moduleButtonPositionPlugin
                                                                        : self.moduleButtonPositionCheckSelf;
                self.growingtk_origin = endPoint;
            }
            completion:^(BOOL finished) {
                self.hidden = YES;
                if (completion) {
                    completion(YES);
                }
            }];
    }
}

- (void)entryClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeWillShowNotification object:nil];

    [self toggle:self.moduleType
        completion:^(BOOL finished) {
            if (finished) {
                [[GrowingTKHomeWindow sharedInstance] toggle];
            }
        }];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (self.autoDock) {
        [self autoDocking:pan];
    } else {
        [self normalMode:pan];
    }
}

- (void)normalMode:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint offsetPoint = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];

    UIView *panView = panGestureRecognizer.view;
    CGFloat newX = panView.growingtk_centerX + offsetPoint.x;
    CGFloat newY = panView.growingtk_centerY + offsetPoint.y;
    if (newX < ENTRY_SIDELENGTH / 2) {
        newX = ENTRY_SIDELENGTH / 2;
    }
    if (newX > GrowingTKScreenWidth - ENTRY_SIDELENGTH / 2) {
        newX = GrowingTKScreenWidth - ENTRY_SIDELENGTH / 2;
    }
    if (newY < ENTRY_SIDELENGTH / 2) {
        newY = ENTRY_SIDELENGTH / 2;
    }
    if (newY > GrowingTKScreenHeight - ENTRY_SIDELENGTH / 2) {
        newY = GrowingTKScreenHeight - ENTRY_SIDELENGTH / 2;
    }
    panView.center = CGPointMake(newX, newY);
    [[NSUserDefaults standardUserDefaults] setObject:@{@"centerX": @(newX), @"centerY": @(newY)}
                                              forKey:@"GrowingTKFloatViewCenterLocation"];
}

- (void)autoDocking:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *panView = panGestureRecognizer.view;
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGestureRecognizer translationInView:panView];
            [panGestureRecognizer setTranslation:CGPointZero inView:panView];
            panView.center = CGPointMake(panView.center.x + translation.x, panView.center.y + translation.y);
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint center = panView.center;
            UIEdgeInsets insets = GrowingTKUtil.keyWindow.growingtk_safeAreaInsets;
            CGFloat padding = 3.0f;

            CGFloat minY = ENTRY_SIDELENGTH / 2 + insets.top + padding;
            CGFloat maxY = CGRectGetMaxY([UIScreen mainScreen].bounds) - insets.bottom - ENTRY_SIDELENGTH / 2 - padding;
            if (center.y > maxY) {
                center.y = maxY;
            }else if (center.y < minY) {
                center.y = minY;
            }
            
            CGFloat minX = ENTRY_SIDELENGTH / 2 + insets.left + padding;
            CGFloat maxX = CGRectGetMaxX([UIScreen mainScreen].bounds) - ENTRY_SIDELENGTH / 2 - insets.right - padding;
            if (center.x > CGRectGetMaxX([UIScreen mainScreen].bounds) / 2.f) {
                center.x = maxX;
            } else {
                center.x = minX;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@{@"centerX": @(center.x), @"centerY": @(center.y)}
                                                      forKey:@"GrowingTKFloatViewCenterLocation"];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 panView.center = center;
                             }];
        }

        default:
            break;
    }
}

#pragma mark - Notification

- (void)orientationDidChange:(NSNotification *)not {
    // TODO: 优化横竖屏适配
    // 这里的横竖屏适配方式不够优雅，位置不是原先位置，但总归还在屏幕内
    if (CGPointEqualToPoint(self.latestPosition, CGPointZero)) {
        return;
    }
    CGPoint point = CGPointZero;
    point.x = self.latestPosition.y;
    point.y = self.latestPosition.x;
    self.latestPosition = point;
}

#pragma mark - Getter & Setter

- (GrowingTKModuleButton *)entryButton {
    if (!_entryButton) {
        _entryButton = [GrowingTKModuleButton moduleButtonWithType:GrowingTKModuleCheckSelf];
        [_entryButton addTarget:self action:@selector(entryClick) forControlEvents:UIControlEventTouchUpInside];
    }

    return _entryButton;
}

- (void)setModuleType:(GrowingTKModule)moduleType {
    _moduleType = moduleType;
    self.growingtk_origin =
        moduleType == GrowingTKModulePlugins ? self.moduleButtonPositionPlugin : self.moduleButtonPositionCheckSelf;
    [self.entryButton toggle:moduleType];
}

- (CGPoint)moduleButtonPositionPlugin {
    // 为什么不用 self.growingtk_safeAreaInsets 呢，因为 self.hidden 可能是 YES，此时得到的 safeAreaInsets = UIEdgeInsetsZero
    UIEdgeInsets insets = GrowingTKUtil.keyWindow.growingtk_safeAreaInsets;
    return CGPointMake(GrowingTKScreenWidth - ENTRY_SIDELENGTH * 2 - 25 - insets.right, insets.top + 5);
}

- (CGPoint)moduleButtonPositionCheckSelf {
    UIEdgeInsets insets = GrowingTKUtil.keyWindow.growingtk_safeAreaInsets;
    return CGPointMake(GrowingTKScreenWidth - ENTRY_SIDELENGTH - 10 - insets.right, insets.top + 5);
}


@end
