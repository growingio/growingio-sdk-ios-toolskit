//
//  GrowingTKLaunchTimePersistence.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/9.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTKLaunchTimePersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKLaunchTimePersistence ()

// Init
@property (nonatomic, assign, readwrite) GrowingTKLaunchTimeType type;
@property (nonatomic, assign, readwrite) double duration;
@property (nonatomic, copy, readwrite) NSString *page;
@property (nonatomic, copy, readwrite) NSString *attributes;

// Common
@property (nonatomic, assign, readwrite) double timestamp;

// Private
@property (nonatomic, copy, readwrite) NSString *day;
@property (nonatomic, copy, readwrite) NSString *time;

@end

@implementation GrowingTKLaunchTimePersistence

- (instancetype)initWithUUID:(NSString *)uuid
                        type:(GrowingTKLaunchTimeType)type
                    duration:(double)duration
                        page:(NSString *)page
                  attributes:(NSString *)attributes
                    createAt:(double)createAt {
    if (self = [super init]) {
        _recordUUID = uuid;
        _type = type;
        _duration = duration;
        _page = page;
        _attributes = attributes;
        _timestamp = createAt;
    }
    return self;
}

#pragma mark - Getter & Setter

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
