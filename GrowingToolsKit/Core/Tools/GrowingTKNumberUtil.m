//
//  GrowingTKNumberUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/11.
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

#import "GrowingTKNumberUtil.h"

@implementation GrowingTKNumberUtil

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingTKNumberUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKNumberUtil alloc] init];
    });
    return instance;
}

#pragma mark - Public Method

- (NSString *)groupingSeparator:(NSNumber *)number {
    self.defaultFormatter.usesGroupingSeparator = YES;
    return [self.defaultFormatter stringFromNumber:number];
}

#pragma mark - Getter & Setter

- (NSNumberFormatter *)defaultFormatter {
    if (!_defaultFormatter) {
        _defaultFormatter = [[NSNumberFormatter alloc] init];
        _defaultFormatter.locale = NSLocale.currentLocale;
        _defaultFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return _defaultFormatter;
}

@end
