//
//  GrowingTKTrackListPlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/19.
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

#import "GrowingTKTrackListPlugin.h"
#import "GrowingTKTrackListViewController.h"

@implementation GrowingTKTrackListPlugin

- (NSString *)name {
    return GrowingTKLocalizedString(@"代码埋点");
}

- (NSString *)icon {
    return @"growingtk_trackList";
}

- (NSString *)pluginName {
    return @"GrowingTKTrackListPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKTrackListViewController *controller = [[GrowingTKTrackListViewController alloc] init];
    [GrowingTKHomeWindow openPlugin:controller];
}

@end
