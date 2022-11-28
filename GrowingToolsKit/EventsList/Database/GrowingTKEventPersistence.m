//
//  GrowingTKEventPersistence.m
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

#import "GrowingTKEventPersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKEventPersistence ()

// Init
@property (nonatomic, copy, readwrite) NSString *eventType;

// Common
@property (nonatomic, copy, readwrite) NSNumber *globalSequenceId;
@property (nonatomic, copy, readwrite) NSString *deviceId;
@property (nonatomic, copy, readwrite) NSString *sessionId;
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, assign, readwrite) double timestamp;

// Private
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, copy, readwrite) NSString *day;
@property (nonatomic, copy, readwrite) NSString *time;

@end

@implementation GrowingTKEventPersistence

#pragma mark - Init

- (instancetype)initWithUUID:(NSString *)uuid
                   eventType:(nullable NSString *)eventType
                  jsonString:(NSString *)jsonString
                      isSend:(BOOL)isSend {
    if (self = [super init]) {
        _eventUUID = uuid;
        _eventType = eventType;
        _rawJsonString = jsonString;
        _isSend = isSend;
    }
    return self;
}

#pragma mark - Getter & Setter

- (NSDictionary *)dictionary {
    if (!_dictionary) {
        NSData *jsonData = [_rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
        _dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    return _dictionary;
}

- (NSString *)eventType {
    if (!_eventType) {
        _eventType = self.dictionary[@"eventType"] ?: self.dictionary[@"t"];
    }
    return _eventType;
}

- (NSNumber *)globalSequenceId {
    if (!_globalSequenceId) {
        _globalSequenceId = self.dictionary[@"globalSequenceId"] ?: self.dictionary[@"gesid"];
    }
    return _globalSequenceId;
}

- (NSString *)deviceId {
    if (!_deviceId) {
        _deviceId = self.dictionary[@"deviceId"] ?: self.dictionary[@"u"];
    }
    return _deviceId;
}

- (NSString *)sessionId {
    if (!_sessionId) {
        _sessionId = self.dictionary[@"sessionId"] ?: self.dictionary[@"s"];
    }
    return _sessionId;
}

- (NSString *)path {
    if (!_path) {
        if ([self.eventType isEqualToString:@"CUSTOM"] || [self.eventType isEqualToString:@"cstm"]) {
            _path = self.dictionary[@"eventName"] ?: self.dictionary[@"n"];
        } else {
            _path = self.dictionary[@"path"] ?: self.dictionary[@"p"];
        }
    }
    return _path;
}

- (double)timestamp {
    if (!_timestamp) {
        NSNumber *t = self.dictionary[@"timestamp"] ?: self.dictionary[@"tm"];
        _timestamp = t.doubleValue;
    }
    return _timestamp;
}

- (NSString *)day {
    if (!_day) {
        _day = [GrowingTKDateUtil.sharedInstance timeStringFromTimestamp:self.timestamp format:@"yyyyMMdd"];
    }
    return _day;
}

- (NSString *)time {
    if (!_time) {
        _time = [GrowingTKDateUtil.sharedInstance timeStringFromTimestamp:self.timestamp format:@"HH:mm:ss"];
    }
    return _time;
}

@end
