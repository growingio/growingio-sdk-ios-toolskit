//
//  GrowingTKHybridJS.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/28.
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

#import "GrowingTKHybridJS.h"
#import "GrowingTKDefine.h"
#import "NSBundle+GrowingTK.h"
#import "GrowingTKSDKUtil.h"

@implementation GrowingTKHybridJS

+ (NSString *)hybridJSCircleScript {
    NSBundle *bundle = [NSBundle growingtk_resourcesBundle:NSClassFromString(GrowingToolsKitName)
                                                bundleName:GrowingToolsKitBundleName];
    NSString *jsPath = [bundle pathForResource:@"gio_hybrid.min" ofType:@"js"];
    if (GrowingTKSDKUtil.sharedInstance.isSDK4thGeneration) {
        jsPath = [bundle pathForResource:@"giokit_touch" ofType:@"js"];
    }
    NSData *jsData = [NSData dataWithContentsOfFile:jsPath];
    NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
    if (GrowingTKSDKUtil.sharedInstance.isSDK4thGeneration) {
        NSString *hybrid = @"(function(){window.GiokitTouchJavascriptBridge={};$js_replacement})();";
        jsString = [hybrid stringByReplacingOccurrencesOfString:@"$js_replacement" withString:jsString];
    }
    return jsString;
}

@end
