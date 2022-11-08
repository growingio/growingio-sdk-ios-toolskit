//
//  GrowingTKDateUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/14.
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

#import "GrowingTKDateUtil.h"

@implementation GrowingTKDateUtil

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingTKDateUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKDateUtil alloc] init];
    });
    return instance;
}

#pragma mark - Public Method

- (NSString *)timeStringFromTimestamp:(double)timestamp {
    return [self timeStringFromTimestamp:timestamp format:nil];
}

- (NSString *)timeStringFromTimestamp:(double)timestamp format:(NSString *_Nullable)format {
    if (format.length == 0) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    self.defaultFormatter.dateFormat = format;
    self.defaultFormatter.timeZone = [NSTimeZone localTimeZone];
    return [self.defaultFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000LL]];
}

- (BOOL)isToday:(double)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000LL];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
               fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                        fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];

    return [today isEqualToDate:otherDate];
}

- (BOOL)isYesterday:(double)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000LL];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
               fromDate:[self dateBySubtractingDays:1]];
    NSDate *tomorrow = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                        fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];

    return [tomorrow isEqualToDate:otherDate];
}

- (NSDate *)dateBySubtractingDays:(NSInteger)days {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1 * days];

    return [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
}

#pragma mark - Getter & Setter

- (NSDateFormatter *)defaultFormatter {
    if (!_defaultFormatter) {
        _defaultFormatter = [[NSDateFormatter alloc] init];
    }
    return _defaultFormatter;
}

@end
