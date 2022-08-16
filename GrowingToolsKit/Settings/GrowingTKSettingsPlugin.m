//
//  GrowingTKSettingsPlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/16.
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

#import "GrowingTKSettingsPlugin.h"
#import "GrowingTKSettingsViewController.h"
#import "GrowingTKSettingsViewController.h"

@implementation GrowingTKSettingsPlugin

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKSettingsPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKSettingsPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"通用设置");
}

- (NSString *)icon {
    return @"growingtk_settings";
}

- (NSString *)pluginName {
    return @"GrowingTKSettingsPlugin";
}

- (NSString *)atModule {
    return GrowingTKLocalizedString(@"设置");
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSettingsViewController *controller = [[GrowingTKSettingsViewController alloc] init];
    [GrowingTKHomeWindow openPlugin:controller];
}

@end
