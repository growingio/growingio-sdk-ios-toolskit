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
    // 代码埋点
    GrowingTKDefaultPluginType_TrackListPlugin,
    // 埋点数据
    GrowingTKDefaultPluginType_EventsListPlugin,
    // 埋点跟踪
    GrowingTKDefaultPluginType_EventTrackPlugin,
    // 日志显示
    GrowingTKDefaultPluginType_LogPlugin,
    // Hybrid测试
    GrowingTKDefaultPluginType_HybridPlugin,
    // xPath查看
    GrowingTKDefaultPluginType_XPathPlugin
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
