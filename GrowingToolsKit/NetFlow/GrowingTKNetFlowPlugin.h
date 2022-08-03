//
//  GrowingTKNetFlowPlugin.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/4.
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

#import "GrowingTKPluginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingTKRequestPersistence;

@interface GrowingTKNetFlowPlugin : NSObject <GrowingTKPluginProtocol>

#pragma mark - GrowingTKPluginProtocol

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NSString *atModule;
@property (nonatomic, strong) NSString *key;

- (void)pluginDidLoad;

#pragma mark - GrowingTKRequest

@property (nonatomic, assign, readonly) NSTimeInterval pluginStartTimestamp;
@property (nonatomic, assign, readonly) NSUInteger requestCount;
@property (nonatomic, assign, readonly) double totalUploadFlow;
@property (nonatomic, assign, readonly) NSUInteger requestFailedCount;

- (void)insertRequest:(GrowingTKRequestPersistence *)request;
- (BOOL)clearAllRequests;
- (NSArray<GrowingTKRequestPersistence *> *)getRequestsWithRequestTimeEarlyThan:(double)requestTime
                                                                       pageSize:(NSUInteger)pageSize;

#pragma mark - URLSessionDataTask

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     delegate:(id<NSURLSessionDataDelegate>)delegate
                                        modes:(NSArray *)modes;

@end

NS_ASSUME_NONNULL_END
