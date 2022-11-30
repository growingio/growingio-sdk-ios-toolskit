//
//  GrowingTKSDKUtil.h
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTKSDKUtil : NSObject

// Common
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *subName;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *urlScheme;
@property (nonatomic, copy, readonly) NSString *urlSchemesInInfoPlist;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *userKey;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy, readonly) NSString *cellularNetworkUploadEventSize;
@property (nonatomic, assign, readonly) BOOL isIntegrated;
@property (nonatomic, assign, readonly) BOOL isInitialized;
@property (nonatomic, assign, readonly) double initializationTime;
@property (nonatomic, assign, readonly) BOOL delayInitialized;
@property (nonatomic, assign, readonly, getter=isAdaptToURLScheme) BOOL adaptToURLScheme;
@property (nonatomic, assign, readonly, getter=isAdaptToDeepLink) BOOL adaptToDeepLink;

// Tracker
@property (nonatomic, copy, readonly) NSString *projectId;
@property (nonatomic, assign, readonly) BOOL debugEnabled;
@property (nonatomic, assign, readonly) NSUInteger cellularDataLimit;
@property (nonatomic, assign, readonly) NSTimeInterval dataUploadInterval;
@property (nonatomic, assign, readonly) NSTimeInterval sessionInterval;
@property (nonatomic, assign, readonly) BOOL dataCollectionEnabled;
@property (nonatomic, assign, readonly) BOOL uploadExceptionEnable;
@property (nonatomic, copy, readonly) NSString *dataCollectionServerHost;
@property (nonatomic, assign, readonly) NSUInteger excludeEvent;
@property (nonatomic, assign, readonly) NSUInteger ignoreField;
@property (nonatomic, assign, readonly) BOOL idMappingEnabled;
@property (nonatomic, assign, readonly) BOOL encryptEnabled;

// AutoTracker
@property (nonatomic, assign, readonly) float impressionScale;

// CDP
@property (nonatomic, copy, readonly) NSString *dataSourceId;

// SDK 2.0
@property (nonatomic, assign, readonly) float sampling;
@property (nonatomic, copy, readonly) NSString *sdk2ndAspectMode;
@property (nonatomic, assign, readonly) BOOL readClipBoardEnabled;
@property (nonatomic, assign, readonly) BOOL asaEnabled;

+ (instancetype)sharedInstance;

- (BOOL)isSDK3rdGeneration;
- (BOOL)isSDK2ndGeneration;
- (BOOL)isSDKAutoTrack;
- (NSArray *)SDK3Modules;
- (NSString *)nameDescription;
- (NSString *)initializationDescription;
- (NSString *)excludeEventDescription;
- (NSString *)ignoreFieldDescription;

- (void)ignoreViewController:(UIViewController *)viewController;
- (void)ignoreView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
