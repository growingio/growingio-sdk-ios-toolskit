//
// GrowingEventFMDatabase.h
// GrowingToolsKit
//
//  Created by YoloMao on 2021/9/13.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

@class GrowingTKFMDatabase;

@interface GrowingTKDatabase : NSObject

+ (instancetype)database;
- (void)createTable:(NSString *)createSql tableName:(NSString *)tableName indexs:(NSArray <NSString *>*)indexs;

#pragma mark - Perform Block

- (void)performDatabaseBlock:(void (^)(GrowingTKFMDatabase *db, NSError *error))block;
- (void)performTransactionBlock:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error))block;

#pragma mark - Error

@property (nonatomic, strong) NSError *databaseError;

- (NSError *)lastError;
- (NSError *)openErrorInDatabase:(GrowingTKFMDatabase *)db;
- (NSError *)readErrorInDatabase:(GrowingTKFMDatabase *)db;
- (NSError *)writeErrorInDatabase:(GrowingTKFMDatabase *)db;
- (NSError *)createDBErrorInDatabase:(GrowingTKFMDatabase *)db;

@end

NS_ASSUME_NONNULL_END
