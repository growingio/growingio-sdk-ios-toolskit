//
//  GrowingTKCrashLogsPersistence.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/7.
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

#import "GrowingTKCrashLogsPersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKCrashLogsPersistence ()

// Init
@property (nonatomic, copy, readwrite) NSString *rawReport;
@property (nonatomic, copy, readwrite) NSString *appleFmt;

// Common
@property (nonatomic, copy, readwrite) NSString *machException;
@property (nonatomic, copy, readwrite) NSString *signal;
@property (nonatomic, copy, readwrite) NSString *reason;
@property (nonatomic, assign, readwrite) double timestamp;

// Private
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, copy, readwrite) NSString *day;
@property (nonatomic, copy, readwrite) NSString *time;

@end

@implementation GrowingTKCrashLogsPersistence

#pragma mark - Init

- (instancetype)initWithUUID:(NSString *)uuid
                   rawReport:(NSString *)rawReport
                    appleFmt:(NSString *)appleFmt {
    if (self = [super init]) {
        _crashUUID = uuid;
        _rawReport = rawReport;
        _appleFmt = appleFmt;
    }
    return self;
}

- (NSString *)stringWithUncaughtExceptionName:(NSString *)name reason:(NSString *)reason {
    return [NSString stringWithFormat:@"*** Terminating app due to uncaught exception '%@', reason: '%@'", name, reason];
}

#pragma mark - Getter & Setter

- (NSDictionary *)dictionary {
    if (!_dictionary) {
        NSData *jsonData = [_rawReport dataUsingEncoding:NSUTF8StringEncoding];
        _dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    return _dictionary;
}

- (NSString *)machException {
    if (!_machException) {
        NSDictionary *error = self.dictionary[@"crash"][@"error"];
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSDictionary *mach = error[@"mach"];
            if ([mach isKindOfClass:[NSDictionary class]]) {
                _machException = mach[@"exception_name"];
            }
        }
    }
    return _machException;
}

- (NSString *)signal {
    if (!_signal) {
        NSDictionary *error = self.dictionary[@"crash"][@"error"];
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSDictionary *signal = error[@"signal"];
            if ([signal isKindOfClass:[NSDictionary class]]) {
                _signal = signal[@"name"];
            }
        }
    }
    return _signal;
}

- (NSString *)reason {
    if (!_reason) {
        NSDictionary *error = self.dictionary[@"crash"][@"error"];
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSDictionary *nsexception = error[@"nsexception"];
            NSDictionary *cppexception = error[@"cpp_exception"];
            if ([nsexception isKindOfClass:[NSDictionary class]] && nsexception.allKeys.count > 0) {
                _reason = [self stringWithUncaughtExceptionName:nsexception[@"name"] reason:error[@"reason"]];
            } else if ([cppexception isKindOfClass:[NSDictionary class]] && cppexception.allKeys.count > 0) {
                _reason = [self stringWithUncaughtExceptionName:cppexception[@"name"] reason:error[@"reason"]];
            } else {
                _reason = @"";
            }
        }
    }
    return _reason;
}

- (double)timestamp {
    if (!_timestamp) {
        NSString *t = self.dictionary[@"report"][@"timestamp"];
        NSDateFormatter *formatter = GrowingTKDateUtil.sharedInstance.defaultFormatter;
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        NSDate *date = [formatter dateFromString:t];
        _timestamp = [date timeIntervalSince1970] * 1000LL;
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
        _time = [GrowingTKDateUtil.sharedInstance timeStringFromTimestamp:self.timestamp format:@"HH:mm"];
    }
    return _time;
}

@end
