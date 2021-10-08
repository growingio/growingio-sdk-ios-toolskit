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

@implementation GrowingTKHybridJS

+ (NSString *)configHybridScript {
    NSString *configString = [NSString
        stringWithFormat:
            @"{\"enableHT\":%@,\"disableImp\":%@,\"phoneWidth\":%f,\"phoneHeight\":%f,\"protocolVersion\":%d}",
            @"false",
            @"true",
            [UIScreen mainScreen].bounds.size.width,
            [UIScreen mainScreen].bounds.size.height,
            1];
    return [NSString stringWithFormat:@"window._vds_hybrid_config = %@", configString];
}

+ (NSString *)hybridJSScript {
    NSBundle *bundle = [NSBundle growingtk_resourcesBundle:NSClassFromString(GrowingToolsKitName)];
    NSString *jsPath = [bundle pathForResource:@"app_hybrid" ofType:@"js"];
    NSData *jsData = [NSData dataWithContentsOfFile:jsPath];
    NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
    return jsString;
}

+ (NSString *)hybridJSCircleScript {
    NSBundle *bundle = [NSBundle growingtk_resourcesBundle:NSClassFromString(GrowingToolsKitName)];
    NSString *jsPath = [bundle pathForResource:@"app_circle_plugin" ofType:@"js"];
    NSData *jsData = [NSData dataWithContentsOfFile:jsPath];
    NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
    return jsString;
}

@end
