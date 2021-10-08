//
//  GrowingTKPermission.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/17.
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

typedef NS_ENUM(NSUInteger, GrowingTKAuthorizationStatus) {
    GrowingTKAuthorizationStatusNotDetermined,
    GrowingTKAuthorizationStatusRestricted,
    GrowingTKAuthorizationStatusDenied,
    GrowingTKAuthorizationStatusAuthorized,
    GrowingTKAuthorizationStatusAlways,     // only location
    GrowingTKAuthorizationStatusWhenInUse,  // only location
    GrowingTKAuthorizationStatusDisabled,   // only location, Settings > Privacy > Location Services switch is off
};

@interface GrowingTKPermission : NSObject

/// 网络权限
+ (void)startListenToNetworkPermissionDidUpdate:(void(^)(GrowingTKAuthorizationStatus status))didUpdateBlock;
+ (void)stopListenToNetworkPermission;

/// 地理位置权限
+ (GrowingTKAuthorizationStatus)locationPermission;

/// 推送权限
+ (GrowingTKAuthorizationStatus)pushPermission;

/// 相机权限
+ (GrowingTKAuthorizationStatus)cameraPermission;

/// 麦克风权限
+ (GrowingTKAuthorizationStatus)audioPermission;

/// 相册权限
+ (GrowingTKAuthorizationStatus)photoPermission;

/// 通讯录权限
+ (GrowingTKAuthorizationStatus)contactsPermission;

/// 日历权限
+ (GrowingTKAuthorizationStatus)calendarPermission;

/// 提醒事项权限
+ (GrowingTKAuthorizationStatus)notesPermission;

@end

NS_ASSUME_NONNULL_END
