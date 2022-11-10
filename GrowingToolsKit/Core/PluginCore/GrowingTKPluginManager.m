//
//  GrowingTKPluginManager.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
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

#import "GrowingTKPluginManager.h"
#import "GrowingTKPluginProtocol.h"
#import "GrowingTKDefine.h"

NSString *GrowingTKDefaultModuleName(void) {
    return GrowingTKLocalizedString(@"SDK工具");
}

@interface GrowingTKPluginManager ()

@property (nonatomic, strong, readwrite) NSMutableArray *dataArray;

@end

@implementation GrowingTKPluginManager

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingTKPluginManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKPluginManager alloc] init];
    });

    return instance;
}

#pragma mark - Public Method

- (void)setupDefaultPlugins {
    // *************** 平台工具 ***************
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_SDKInfoPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_EventsListPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_XPathTrackPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_NetFlowPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_LogPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_HybridPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_RealtimePlugin];
    
    // *************** 性能 ***************
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_CrashMonitorPlugin];
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_LaunchTimePlugin];
    
    // *************** 设置 ***************
    [self addPluginWithPluginType:GrowingTKDefaultPluginType_GeneralSettingsPlugin];
}

- (void)addPluginWithTitle:(NSString *)title
                      icon:(NSString *)iconName
                pluginName:(NSString *)pluginName
                  atModule:(NSString *)moduleName
                 uniqueKey:(NSString *)uniqueKey {
    NSMutableDictionary *pluginDic = [self findPluginAtModule:moduleName key:uniqueKey];
    pluginDic[@"name"] = title;
    pluginDic[@"icon"] = iconName;
    pluginDic[@"pluginName"] = pluginName;
    pluginDic[@"key"] = uniqueKey;
}

#pragma mark - Private Method

- (void)addPluginWithPluginType:(GrowingTKDefaultPluginType)pluginType {
    id<GrowingTKPluginProtocol> plugin = [self getDefaultPluginWithPluginType:pluginType];
    if (!plugin) {
        return;
    }
    [self addPluginWithTitle:plugin.name
                        icon:plugin.icon
                  pluginName:plugin.pluginName
                    atModule:plugin.atModule
                   uniqueKey:plugin.key];
}

- (NSMutableDictionary *)findPluginAtModule:(NSString *)module key:(NSString *)uniqueKey {
    __block NSMutableDictionary *pluginDic = [NSMutableDictionary dictionary];
    pluginDic[@"moduleName"] = module;
    __block BOOL hasModule = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSDictionary *moduleDic = obj;
        NSString *moduleName = moduleDic[@"moduleName"];
        if ([moduleName isEqualToString:module]) {
            hasModule = YES;
            NSMutableArray *pluginArray = moduleDic[@"pluginArray"];
            if (pluginArray) {
                BOOL hasPlugin = NO;
                for (NSMutableDictionary *p in pluginArray) {
                    if ([p[@"key"] isEqualToString:uniqueKey]) {
                        pluginDic = p;
                        hasPlugin = YES;
                        break;
                    }
                }
                if (!hasPlugin) {
                    [pluginArray addObject:pluginDic];
                }
            }
            *stop = YES;
        }
    }];
    if (!hasModule) {
        [self registerModule:module withPlugin:pluginDic];
    }
    return pluginDic;
}

- (void)registerModule:(NSString *)moduleName withPlugin:(NSDictionary *)pluginDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:pluginDic, nil];
    [dic setValue:moduleName forKey:@"moduleName"];
    [dic setValue:array forKey:@"pluginArray"];

    if (!self.dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    [self.dataArray addObject:dic];
}

- (id<GrowingTKPluginProtocol>)getDefaultPluginWithPluginType:(GrowingTKDefaultPluginType)pluginType {
    NSString *classString = @{
        @(GrowingTKDefaultPluginType_SDKInfoPlugin): @"GrowingTKSDKInfoPlugin",
        @(GrowingTKDefaultPluginType_EventsListPlugin): @"GrowingTKEventsListPlugin",
        @(GrowingTKDefaultPluginType_XPathTrackPlugin): @"GrowingTKXPathTrackPlugin",
        @(GrowingTKDefaultPluginType_NetFlowPlugin): @"GrowingTKNetFlowPlugin",
        @(GrowingTKDefaultPluginType_LogPlugin): @"GrowingTKLogPlugin",
        @(GrowingTKDefaultPluginType_HybridPlugin): @"GrowingTKHybridPlugin",
        @(GrowingTKDefaultPluginType_RealtimePlugin): @"GrowingTKRealtimePlugin",
        @(GrowingTKDefaultPluginType_CrashMonitorPlugin): @"GrowingTKCrashMonitorPlugin",
        @(GrowingTKDefaultPluginType_LaunchTimePlugin): @"GrowingTKLaunchTimePlugin",
        @(GrowingTKDefaultPluginType_GeneralSettingsPlugin): @"GrowingTKSettingsPlugin",
    }[@(pluginType)];

    Class class = NSClassFromString(classString);
    SEL sharedInstance = NSSelectorFromString(@"plugin");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([class respondsToSelector:sharedInstance]) {
        return (id<GrowingTKPluginProtocol>)[class performSelector:sharedInstance];
    }
#pragma clang diagnostic pop
    
    return (id<GrowingTKPluginProtocol>)[[class alloc] init];
}

@end
