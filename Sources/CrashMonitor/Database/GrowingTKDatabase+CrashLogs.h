//
//  GrowingTKDatabase+CrashLogs.h
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

#import "GrowingTKDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingTKCrashLogsPersistence;

@interface GrowingTKDatabase (CrashLogs)

- (void)createCrashLogsTable;

- (NSInteger)countOfCrashLogs;

- (NSArray<GrowingTKCrashLogsPersistence *> *)getAllCrashLogs;

- (BOOL)insertCrashLog:(GrowingTKCrashLogsPersistence *)crashLog;

- (BOOL)insertCrashLogs:(NSArray<GrowingTKCrashLogsPersistence *> *)crashLogs;

- (BOOL)deleteCrashLog:(NSString *)key;

- (BOOL)deleteCrashLogs:(NSArray<NSString *> *)keys;

- (BOOL)clearAllCrashLogs;

@end

NS_ASSUME_NONNULL_END
