//
//  GrowingTKCrashMonitorPlugin.m
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

#import "GrowingTKCrashMonitorPlugin.h"
#import "GrowingTKCrashLogsViewController.h"
#import "GrowingTKDatabase+CrashLogs.h"
#import "GrowingTKCrashLogsPersistence.h"

#import "GrowingAPM+Private.h"

#import "GrowingTKSDKUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+GrowingTKSwizzle.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"

@interface GrowingTKCrashMonitorPlugin ()

@end

@implementation GrowingTKCrashMonitorPlugin

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _db = [GrowingTKDatabase database];
        [_db createCrashLogsTable];
        
        [[NSNotificationCenter defaultCenter] addObserver:_db
                                                 selector:@selector(clearAllCrashLogs)
                                                     name:GrowingTKClearAllCrashLogsNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKCrashMonitorPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKCrashMonitorPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"错误报告");
}

- (NSString *)icon {
    return @"growingtk_crashMonitor";
}

- (NSString *)pluginName {
    return @"GrowingTKCrashMonitorPlugin";
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
        GrowingTKCrashLogsViewController *controller = [[GrowingTKCrashLogsViewController alloc] init];
        [GrowingTKHomeWindow openPlugin:controller];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成SDK，请参考帮助文档进行集成")];
    }
}

#pragma mark - GrowingAPMCrashMonitorDelegate

- (void)growingapm_crashMonitorHandleWithReports:(NSArray *)reports
                                       completed:(BOOL)completed
                                           error:(NSError *)error {
    if (!completed || error) {
        return;
    }
    
    for(id report in reports) {
        if ([report isKindOfClass:[NSDictionary class]]) {
            NSString *rawReport = nil;
            id originReport = report[@"rawReport"];
            if ([originReport isKindOfClass:[NSDictionary class]]) {
                rawReport = [GrowingTKUtil convertJSONFromJSONObject:originReport];
            }
            NSString *appleFmt = report[@"AppleFmt"];
            
            GrowingTKCrashLogsPersistence *p = [[GrowingTKCrashLogsPersistence alloc] initWithUUID:[[NSUUID UUID] UUIDString]
                                                                                         rawReport:rawReport
                                                                                          appleFmt:appleFmt];
            [GrowingTKCrashMonitorPlugin.plugin.db insertCrashLog:p];
        }
    }
}

@end
