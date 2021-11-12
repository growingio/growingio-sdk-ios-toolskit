//
//  GrowingTKRequestPersistence.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTKRequestPersistence : NSObject

@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSString *requestBody;
@property (nonatomic, copy, readonly) NSString *requestBodyLength;
@property (nonatomic, copy, readonly) NSDictionary *requestHeader;
@property (nonatomic, copy, readonly) NSString *statusCode;
@property (nonatomic, copy, readonly) NSString *status;
@property (nonatomic, copy, readonly) NSString *responseBody;
@property (nonatomic, copy, readonly) NSDictionary *responseHeader;
@property (nonatomic, copy, readonly) NSString *mineType;
@property (nonatomic, copy, readonly) NSString *startTime;
@property (nonatomic, assign, readonly) NSTimeInterval startTimestamp;
@property (nonatomic, assign, readonly) NSTimeInterval endTimestamp;
@property (nonatomic, copy, readonly) NSString *totalDuration;
@property (nonatomic, copy, readonly) NSString *uploadFlow;
@property (nonatomic, copy, readonly) NSString *downFlow;
@property (nonatomic, copy, readonly) NSString *viewController;

@property (nonatomic, copy, readonly) NSString *rawJsonString;
@property (nonatomic, copy, readonly) NSString *day;

+ (void)dealWithRequest:(NSURLRequest *)request
               response:(NSURLResponse *)response
           responseData:(NSData *)responseData
                  error:(NSError *)error
              startTime:(NSTimeInterval)startTime
         completedBlock:(void (^)(GrowingTKRequestPersistence *))completedBlock;

- (instancetype)initWithRequestBody:(NSString *)requestBody
                       responseBody:(NSString *)responseBody
                         jsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
