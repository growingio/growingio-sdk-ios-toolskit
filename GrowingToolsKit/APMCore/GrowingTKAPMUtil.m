//
//  GrowingTKAPMUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/7.
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

#ifdef DEBUG
#import "GrowingTKAPMUtil.h"
#import "GrowingTKDefine.h"
#import "GrowingTKSDKUtil.h"
#import "NSObject+GrowingTKSwizzle.h"

#import "GrowingAPM+Private.h"

/*
 GrowingAPM setupMonitors 分为 2 种：
 1. GrowingAnalytics SDK (3.0) 集成 APM Module：假定用户会在 main 函数中调用 +[GrowingAPM setupMonitors]；如果用户没调用，则会收集不到数据
 2. SDK 2.0 / SDK 3.0 未集成 APM Module：在 C++ Init 时机调用 +[GrowingAPM setupMonitors]，减少用户集成步骤
 
 GrowingAPM 初始化分为 3 种：
 1. GrowingAnalytics SDK (3.0) 集成 APM Module：不论是否初始化成功，都对其中的 -[GrowingAPMModule growingModInit:] 方法进行 hook
 2. GrowingAnalytics SDK (3.0) 未集成 APM Module：在 +[GrowingToolsKit start] setupDefaultPlugins 之后，初始化 GrowingAPM
 3. Growing SDK (2.0)：在 +[GrowingToolsKit start] setupDefaultPlugins 之后，初始化 GrowingAPM
 */

@implementation GrowingTKAPMUtil

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKAPMUtil alloc] init];
    });
    return instance;
}

#pragma mark - Swizzle

+ (void)load {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        // *************** SDK 3.0 ***************
        Class class = NSClassFromString(@"GrowingAPMModule");
        if (!class) {
            // 没有集成 APM Module
            [[NSNotificationCenter defaultCenter] addObserver:[GrowingTKAPMUtil sharedInstance]
                                                     selector:@selector(growingtk_APMInit)
                                                         name:GrowingTKSetupDefaultPluginsNotification
                                                       object:nil];
            return;
        }
        
        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"growingModInit:");
        id block = ^(id apmModule, id context) {
            return growingtk_growingAPMModInit(invocation, apmModule, context);
        };
        invocation = [class growingtk_swizzleMethod:selector withBlock:block error:nil];
    } else if (GrowingTKSDKUtil.sharedInstance.isSDK2ndGeneration) {
        // *************** SDK 2.0 ***************
        [[NSNotificationCenter defaultCenter] addObserver:[GrowingTKAPMUtil sharedInstance]
                                                 selector:@selector(growingtk_APMInit)
                                                     name:GrowingTKSetupDefaultPluginsNotification
                                                   object:nil];
    }
}

__used __attribute__((constructor(62500))) static void setupMonitors(void) {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        // *************** SDK 3.0 ***************
        Class class = NSClassFromString(@"GrowingAPMModule");
        if (!class) {
            // 没有集成 APM Module
            [GrowingAPM setupMonitors];
        }
    } else if (GrowingTKSDKUtil.sharedInstance.isSDK2ndGeneration) {
        // *************** SDK 2.0 ***************
        [GrowingAPM setupMonitors];
    }
}

static void growingtk_growingAPMModInit(NSInvocation *invocation, id apmModule, id context) {
    if (!invocation) {
        return;
    }
    
    // 将其中 GrowingAPM 初始化部分改成开启全部监控功能，并为 GioKit 添加回调
    [GrowingTKAPMUtil.sharedInstance growingtk_APMInit];
    
    [invocation retainArguments];
    [invocation setArgument:&context atIndex:2];
    [invocation invokeWithTarget:apmModule];
}

- (void)growingtk_APMInit {
    GrowingAPMConfig *config = [GrowingAPMConfig config];
    config.monitors = GrowingAPMMonitorsCrash | GrowingAPMMonitorsUserInterface;
    [GrowingAPM startWithConfig:config];
    
    GrowingAPM *apm = GrowingAPM.sharedInstance;
    {
        id plugin = nil;
        Class class = NSClassFromString(@"GrowingTKCrashMonitorPlugin");
        SEL sharedInstance = NSSelectorFromString(@"plugin");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([class respondsToSelector:sharedInstance]) {
            plugin = [class performSelector:sharedInstance];
        }
    #pragma clang diagnostic pop
        if (plugin) {
            if (config.monitors & GrowingAPMMonitorsCrash) {
                [apm.crashMonitor addMonitorDelegate:plugin];
            }
        }
    }
    
    {
        id plugin = nil;
        Class class = NSClassFromString(@"GrowingTKLaunchTimePlugin");
        SEL sharedInstance = NSSelectorFromString(@"plugin");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([class respondsToSelector:sharedInstance]) {
            plugin = [class performSelector:sharedInstance];
        }
    #pragma clang diagnostic pop
        if (plugin) {
            if (config.monitors & GrowingAPMMonitorsUserInterface) {
                [apm.loadMonitor addMonitorDelegate:plugin];
            }
        }
    }
}

@end
#endif
