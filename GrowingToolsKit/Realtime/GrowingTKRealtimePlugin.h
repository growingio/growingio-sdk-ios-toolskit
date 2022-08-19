//
//  GrowingTKRealtimePlugin.h
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

#import "GrowingTKPluginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTKRealtimePlugin : NSObject <GrowingTKPluginProtocol>

#pragma mark - GrowingTKPluginProtocol

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NSString *atModule;
@property (nonatomic, strong) NSString *key;

+ (instancetype)plugin;
- (void)pluginDidLoad;

@end

NS_ASSUME_NONNULL_END
