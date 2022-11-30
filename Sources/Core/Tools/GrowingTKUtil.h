//
//  GrowingTKUtil.h
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTKUtil : NSObject

+ (UIViewController *)topViewControllerForKeyWindow;

+ (UIViewController *)topViewControllerForHomeWindow;

+ (UIWindow *)keyWindow;

+ (void)openAppSetting;

+ (BOOL)isIPAddress:(NSString *)string;

+ (BOOL)isDomain:(NSString *)string;

+ (NSString *)convertJsonFromData:(NSData *)data;

+ (NSString *)convertJSONFromJSONObject:(id)jsonObject;

+ (NSDictionary *)convertDicFromData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
