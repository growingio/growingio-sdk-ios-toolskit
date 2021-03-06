//
//  GrowingTKDatabase+Event.h
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

#import "GrowingTKDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@class GrowingTKEventPersistence;

@interface GrowingTKDatabase (Event)

- (void)createEventsTable;

- (NSInteger)countOfEvents;

- (NSArray<GrowingTKEventPersistence *> *)getAllEvents;

- (NSArray<GrowingTKEventPersistence *> *)getEventsByEventTypes:(NSArray <NSString *>*)eventTypes;

- (BOOL)insertEvent:(GrowingTKEventPersistence *)event;

- (BOOL)insertEvents:(NSArray<GrowingTKEventPersistence *> *)events;

- (BOOL)updateEventDidSend:(NSString *)key;

- (BOOL)deleteEvent:(NSString *)key;

- (BOOL)deleteEvents:(NSArray<NSString *> *)keys;

- (BOOL)clearAllEvents;

- (BOOL)cleanExpiredEventIfNeeded;

@end

NS_ASSUME_NONNULL_END
