//
//  GrowingTKDefine.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/12.
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

#ifndef GrowingTKDefine_h
#define GrowingTKDefine_h

#import "GrowingTKDevice.h"
#import "GrowingTKLocalization.h"

FOUNDATION_EXTERN NSString *const GrowingToolsKitName;

FOUNDATION_EXTERN NSString *const GrowingTKSetupDefaultPluginsNotification;
FOUNDATION_EXTERN NSString *const GrowingTKHomeWillShowNotification;
FOUNDATION_EXTERN NSString *const GrowingTKHomeShouldHideNotification;

FOUNDATION_EXTERN NSString *const GrowingTKShowEventsListNotification;

FOUNDATION_EXTERN NSString *const GrowingTKClearAllEventNotification;
FOUNDATION_EXTERN NSString *const GrowingTKClearAllRequestsNotification;
FOUNDATION_EXTERN NSString *const GrowingTKClearAllPerformanceDataNotification;

FOUNDATION_EXTERN NSString *const GrowingTKRealtimeEventNotification;
FOUNDATION_EXTERN NSString *const GrowingTKRealtimeStatusNotification;

FOUNDATION_EXTERN NSString *const GrowingTKLocalStorageKeyOpenCrashMonitor;
FOUNDATION_EXTERN NSString *const GrowingTKLocalStorageKeyOpenLaunchTime;

typedef NS_ENUM(NSUInteger, GrowingTKModule) {
    GrowingTKModulePlugins,
    GrowingTKModuleCheckSelf
};

#ifdef DEBUG
#define GTKLog(fmt, ...)         \
    NSLog((@"[文件名:%s]\n"   \
            "[函数名:%s]\n"   \
            "[行号:%d] \n" fmt), \
          __FILE__,              \
          __FUNCTION__,          \
          __LINE__,              \
          ##__VA_ARGS__);
#else
#define GTKLog(...) ;
#endif

#define GrowingTKScreenWidth [UIScreen mainScreen].bounds.size.width
#define GrowingTKScreenHeight [UIScreen mainScreen].bounds.size.height

// GrowingToolsKit默认位置
#define GrowingTKStartingPosition CGPointMake(3.0, GrowingTKScreenHeight * 2.0 / 3.0)

// 根据750*1334分辨率计算size
#define GrowingTKSizeFrom750(x)                                                              \
    (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation) \
         ? ((x)*GrowingTKScreenHeight / 750)                                                 \
         : ((x)*GrowingTKScreenWidth / 750))

#define ENTRY_SIDELENGTH 50.0f

#endif /* GrowingTKDefine_h */
