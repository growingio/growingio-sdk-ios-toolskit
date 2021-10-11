//
//  GrowingTKSDKInfoPlugin.m
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

#import "GrowingTKSDKInfoPlugin.h"
#import "GrowingTKSDKInfoViewController.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"

@implementation GrowingTKSDKInfoPlugin

- (NSString *)name {
    return GrowingTKLocalizedString(@"SDK信息");
}

- (NSString *)icon {
    return @"growingtk_sdkInfo";
}

- (NSString *)pluginName {
    return @"GrowingTKSDKInfoPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isIntegrated) {
        GrowingTKSDKInfoViewController *controller = [[GrowingTKSDKInfoViewController alloc] init];
        [GrowingTKHomeWindow openPlugin:controller];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成SDK，请参考帮助文档进行集成")];
    }
}

@end
