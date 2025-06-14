//
//  GrowingRealToolsKit.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/10/8.
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

#import "GrowingRealToolsKit.h"
#import "GrowingTKDefine.h"
#import "GrowingTKPluginManager.h"
#import "GrowingTKEntryWindow.h"
#import "NSBundle+GrowingTK.h"

NSString *const GrowingToolsKitName = @"GrowingToolsKit";
NSString *const GrowingToolsKitBundleName = @"GrowingToolsKitResource";

NSString *const GrowingTKSetupDefaultPluginsNotification = @"GrowingTKSetupDefaultPluginsNotification";

NSString *const GrowingTKHomeWillShowNotification = @"GrowingTKHomeWillShowNotification";
NSString *const GrowingTKHomeShouldHideNotification = @"GrowingTKHomeShouldHideNotification";

NSString *const GrowingTKShowEventsListNotification = @"GrowingTKShowEventsListNotification";

NSString *const GrowingTKClearAllEventNotification = @"GrowingTKClearAllEventNotification";
NSString *const GrowingTKClearAllRequestsNotification = @"GrowingTKClearAllRequestsNotification";

NSString *const GrowingTKRealtimeEventNotification = @"GrowingTKRealtimeEventNotification";
NSString *const GrowingTKRealtimeStatusNotification = @"GrowingTKRealtimeStatusNotification";

@interface GrowingRealToolsKit ()

@end

@implementation GrowingRealToolsKit

static GrowingRealToolsKit *instance = nil;

#pragma mark - Init

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingRealToolsKit alloc] init];
    });
    return instance;
}

+ (void)start {
    CGPoint defaultPosition = GrowingTKStartingPosition;
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingTKFloatViewCenterLocation"];
    if (dict && dict[@"centerX"] && dict[@"centerY"]) {
        defaultPosition = CGPointMake([dict[@"centerX"] integerValue] - ENTRY_SIDELENGTH / 2,
                                      [dict[@"centerY"] integerValue] - ENTRY_SIDELENGTH / 2);
    }
    if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
        defaultPosition = CGPointZero;
    }
    [self startWithPosition:defaultPosition autoDock:YES];
}

+ (void)startWithPosition:(CGPoint)position autoDock:(BOOL)autoDock {
    if (![GrowingTKUseInRelease activeOrNot]) {
        return;
    }
    
    if (instance) {
        // has install
        return;
    }

    [[GrowingTKPluginManager sharedInstance] setupDefaultPlugins];
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKSetupDefaultPluginsNotification object:nil];
    [[self sharedInstance] initEntry:position autoDock:autoDock];
}

- (void)initEntry:(CGPoint)position autoDock:(BOOL)autoDock {
    [GrowingTKEntryWindow startWithPoint:position autoDock:autoDock];
}

+ (NSString *)version {
#if SWIFT_PACKAGE
    return @"-spm";
#else
    // 兼容静态库方式集成
    NSBundle *imageBundle = [NSBundle growingtk_resourcesBundle:NSClassFromString(GrowingToolsKitName)
                                                     bundleName:GrowingToolsKitBundleName];
    return imageBundle.infoDictionary[@"CFBundleShortVersionString"];
#endif
}

@end
