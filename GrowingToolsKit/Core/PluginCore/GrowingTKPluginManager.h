//
//  GrowingTKPluginManager.h
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GrowingTKDefaultPluginType) {
    // *************** SDK工具 ***************
    // SDK信息
    GrowingTKDefaultPluginType_SDKInfoPlugin,
    // 事件库
    GrowingTKDefaultPluginType_EventsListPlugin,
    // XPath跟踪
    GrowingTKDefaultPluginType_XPathTrackPlugin,
    // 网络记录
    GrowingTKDefaultPluginType_NetFlowPlugin,
    // 日志显示
    GrowingTKDefaultPluginType_LogPlugin,
    // Hybrid测试
    GrowingTKDefaultPluginType_HybridPlugin,
    // 实时事件
    GrowingTKDefaultPluginType_RealtimePlugin,
    
    // *************** 性能 ***************
    // 错误报告
    GrowingTKDefaultPluginType_CrashMonitorPlugin,
    // 启动耗时
    GrowingTKDefaultPluginType_LaunchTimePlugin,
    
    // *************** 设置 ***************
    // 通用设置
    GrowingTKDefaultPluginType_GeneralSettingsPlugin,
};

@interface GrowingTKPluginManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *dataArray;

+ (instancetype)sharedInstance;
- (void)setupDefaultPlugins;

//外部扩展
- (void)addPluginWithTitle:(NSString *)title
                      icon:(NSString *)iconName
                pluginName:(NSString *)pluginName
                  atModule:(NSString *)moduleName
                 uniqueKey:(NSString *)uniqueKey;

@end

NS_ASSUME_NONNULL_END
