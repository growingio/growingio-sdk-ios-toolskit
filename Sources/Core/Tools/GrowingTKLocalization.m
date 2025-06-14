//
//  GrowingTKLocalization.m
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

#import "GrowingTKLocalization.h"
#import "GrowingTKDefine.h"
#import "NSBundle+GrowingTK.h"

@implementation GrowingTKLocalization

+ (NSString *)localizedString:(NSString *)string {
    NSString *language = NSLocale.preferredLanguages.firstObject;
    if (language.length == 0) {
        return string;
    }

    NSString *fileName = [language hasPrefix:@"en"] ? @"en" : @"zh-Hans";
    NSBundle *resourcesBundle = [NSBundle growingtk_resourcesBundle:NSClassFromString(GrowingToolsKitName)
                                                         bundleName:GrowingToolsKitBundleName];
    NSBundle *bundle = [NSBundle growingtk_localizedBundleWithFileName:fileName resourcesBundle:resourcesBundle];
    NSString *localizedString = [bundle localizedStringForKey:string value:nil table:GrowingToolsKitName];
    if (!localizedString) {
        localizedString = string;
    }
    return localizedString;
}

@end
