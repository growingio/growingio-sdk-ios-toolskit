//
//  SDKUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/12/20.
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

#import "SDKUtil.h"
#ifdef DEBUG
#import <GrowingToolsKit/GrowingToolsKit.h>
#endif

#if defined(__IPHONE_14_0)
@import AppTrackingTransparency;
#endif

@implementation SDKUtil

+ (void)start {
#ifdef DEBUG
    [GrowingToolsKit start];
#endif
    
#if SDK3rd
    
#if DELAY_INITIALIZED
    [self requestTrackingAuthorizationWithCompletionHandler:^{
        [self SDK3rdStart];
    }];
#else
    [self SDK3rdStart];
#endif
    
#elif SDK2nd
    
#if DELAY_INITIALIZED
    [self requestTrackingAuthorizationWithCompletionHandler:^{
        [self SDK2ndStart];
    }];
#else
    [self SDK2ndStart];
#endif
    
#endif
}

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(void))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                switch (status) {
                    case ATTrackingManagerAuthorizationStatusDenied:
                        //用户拒绝向App授权
                        break;
                    case ATTrackingManagerAuthorizationStatusAuthorized:
                        //用户同意向App授权
                        break;
                    case ATTrackingManagerAuthorizationStatusNotDetermined:
                        // 用户未做选择或未弹窗，需要在合适的应用状态重新调用一次
                        // Calls to the API only prompt when the application state is UIApplicationStateActive.
                        // 参考文档：https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorization
                        break;
                    case ATTrackingManagerAuthorizationStatusRestricted:
                        //用户在系统级别开启了限制广告追踪
                        break;
                    default:
                        break;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler();
                    }
                });
            }];
        } else {
            if (handler) {
                handler();
            }
        }
    });
}

+ (void)SDK2ndStart {
#if SDK2nd
    [Growing setEnableLog:YES];
    [Growing setFlushInterval:3.0f];
    [Growing setAsaEnabled:NO];
    [Growing setReadClipBoardEnable:NO];
    [Growing startWithAccountId:@"0a1b4118dd954ec3bcc69da5138bdb96"];
#endif
}

+ (void)SDK3rdStart {
#if SDK3rd
    GrowingSDKConfiguration *configuration = [GrowingSDKConfiguration configurationWithProjectId:@"8f9b5dfc7c57af4d"];
    configuration.debugEnabled = YES;
    configuration.encryptEnabled = YES;
    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";
#if SDKCDP
    configuration.dataSourceId = @"1234567890";
#endif
    [GrowingSDK startWithConfiguration:configuration launchOptions:nil];
#endif
}

@end
