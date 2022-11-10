//
//  GrowingTKLaunchTimePlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/8.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTKLaunchTimePlugin.h"
#import "GrowingTKLaunchTimeViewController.h"
#import "GrowingTKDatabase+LaunchTime.h"
#import "GrowingTKLaunchTimePersistence.h"

#import "GrowingTKSDKUtil.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"

#import "GrowingAPM+Private.h"
#if __has_include(<GrowingAPMUIMonitor/GrowingAPMUIMonitor.h>)
#import <GrowingAPMUIMonitor/GrowingAPMUIMonitor.h>
#else
#import "GrowingAPMUIMonitor.h"
#endif

@interface GrowingTKLaunchTimePlugin ()

@end

@implementation GrowingTKLaunchTimePlugin

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _db = [GrowingTKDatabase database];
        [_db createLaunchTimeTable];

        [[NSNotificationCenter defaultCenter] addObserver:_db
                                                 selector:@selector(clearAllLaunchTime)
                                                     name:GrowingTKClearAllPerformanceDataNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKLaunchTimePlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKLaunchTimePlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"启动耗时");
}

- (NSString *)icon {
    return @"growingtk_uiMonitor";
}

- (NSString *)pluginName {
    return @"GrowingTKLaunchTimePlugin";
}

- (NSString *)atModule {
    return GrowingTKLocalizedString(@"性能");
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isIntegrated) {
        GrowingTKLaunchTimeViewController *controller = [[GrowingTKLaunchTimeViewController alloc] init];
        [GrowingTKHomeWindow openPlugin:controller];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成SDK，请参考帮助文档进行集成")];
    }
}

#pragma mark - GrowingAPMLaunchTimeDelegate

- (void)growingapm_UIMonitorHandleWithPageName:(NSString *)pageName
                                  loadDuration:(double)loadDuration
                                    rebootTime:(double)rebootTime
                                        isWarm:(double)isWarm {
    if (rebootTime > 0) {
        NSString *name = GrowingTKLocalizedString(@"应用启动");
        NSString *attributes = @"";
        GrowingTKLaunchTimeType type = GrowingTKLaunchTimeTypeAppLaunch;
        if (isWarm) {
            name = GrowingTKLocalizedString(@"应用恢复");
            type = GrowingTKLaunchTimeTypeAppRestart;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSDictionary *dic = [[GrowingAPMUIMonitor sharedInstance] performSelector:NSSelectorFromString(@"coldRebootMonitorDetails")];
            attributes = [GrowingTKUtil convertJSONFromJSONObject:dic];
#pragma clang diagnostic pop
        }
        
        GrowingTKLaunchTimePersistence *p = [[GrowingTKLaunchTimePersistence alloc] initWithUUID:[[NSUUID UUID] UUIDString]
                                                                                            type:type
                                                                                        duration:rebootTime
                                                                                            page:name
                                                                                      attributes:attributes
                                                                                        createAt:[[NSDate date] timeIntervalSince1970] * 1000LL];
        [GrowingTKLaunchTimePlugin.plugin.db insertLaunchTime:p];
    }
    
    // 热启动的页面加载时长不在 GioKit 中展示
    if (!isWarm) {
        // Page Load
        GrowingTKLaunchTimePersistence *p = [[GrowingTKLaunchTimePersistence alloc] initWithUUID:[[NSUUID UUID] UUIDString]
                                                                                            type:GrowingTKLaunchTimeTypePageLoad
                                                                                        duration:loadDuration
                                                                                            page:pageName
                                                                                      attributes:@""
                                                                                        createAt:[[NSDate date] timeIntervalSince1970] * 1000LL];
        [GrowingTKLaunchTimePlugin.plugin.db insertLaunchTime:p];
    }
}

@end
