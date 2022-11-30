//
//  GrowingTKEventPersistence.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/13.
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

@interface GrowingTKEventPersistence : NSObject

// Init
@property (nonatomic, copy, readonly) NSString *eventUUID;
@property (nonatomic, copy, readonly) NSString *eventType;
@property (nonatomic, copy, readonly) NSString *rawJsonString;
@property (nonatomic, assign, readonly) BOOL isSend;

// Common
@property (nonatomic, copy, readonly) NSNumber *globalSequenceId;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, assign, readonly) double timestamp;

// Private
@property (nonatomic, copy, readonly) NSString *day;
@property (nonatomic, copy, readonly) NSString *time;

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(nullable NSString *)eventType
                  jsonString:(NSString *)jsonString
                      isSend:(BOOL)isSend;

@end

NS_ASSUME_NONNULL_END
