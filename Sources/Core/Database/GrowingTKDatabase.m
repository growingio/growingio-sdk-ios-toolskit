

//
// GrowingEventFMDatabase.m
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

#import "GrowingTKDatabase.h"
#import "GrowingTKFMDB.h"

typedef NS_ENUM(NSInteger, GrowingTKDatabaseError) {
    GrowingTKDatabaseOpenError = 500,  /// 打开数据库错误
    GrowingTKDatabaseWriteError,       /// 数据库写入错误
    GrowingTKDatabaseReadError,        /// 数据库读取错误
    GrowingTKDatabaseCreateDBError,    /// 创建数据库错误
};

static NSString *const kGrowingTKDatabaseErrorDomain = @"com.growing.toolskit.event.database.error";
static NSString *const kGrowingTKResidentDirName = @"com.growingio.core";
static NSString *const kGrowingTKDirCommonPrefix = @"com.growingio.";

@interface GrowingTKDatabase ()

@property (nonatomic, strong) GrowingTKFMDatabaseQueue *db;

@end

@implementation GrowingTKDatabase

#pragma mark - Init

+ (instancetype)database {
    static GrowingTKDatabase *database;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self makeDirByFileName:self.defaultPath];
        database = [[self alloc] initWithFilePath:self.defaultPath];
    });
    
    return database;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        _db = [GrowingTKFMDatabaseQueue databaseQueueWithPath:filePath];
        [self vacuum];
    }

    return self;
}

#pragma mark - Public Methods

- (void)createTable:(NSString *)createSql tableName:(NSString *)tableName indexs:(NSArray <NSString *>*)indexs {
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        if (![db executeUpdate:createSql]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        
        NSString *createIndexSql = @"CREATE INDEX IF NOT EXISTS eventstable_%@_index ON %@ (%@);";
        for (NSString *index in indexs) {
            NSString *create = [NSString stringWithFormat:createIndexSql, index, tableName, index];
            if (![db executeUpdate:create]) {
                self.databaseError = [self createDBErrorInDatabase:db];
                return;
            }
        }
    }];
}

#pragma mark - Private Methods

- (BOOL)vacuum {
    if (!isExecuteVacuum()) {
        return YES;
    }

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"VACUUM"];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

static BOOL isExecuteVacuum() {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *beforeDate = [userDefault objectForKey:@"GrowingTKDatabaseVACUUM"];
    NSDate *nowDate = [NSDate date];

    if (beforeDate) {
        NSDateComponents *delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                  fromDate:beforeDate
                                                                    toDate:nowDate
                                                                   options:0];
        BOOL flag = delta.day > 7 || delta.day < 0;
        if (flag) {
            [userDefault setObject:nowDate forKey:@"GrowingTKDatabaseVACUUM"];
            [userDefault synchronize];
        }
        return flag;
    } else {
        [userDefault setObject:nowDate forKey:@"GrowingTKDatabaseVACUUM"];
        [userDefault synchronize];
        return YES;
    }
}

+ (NSString *)defaultPath {
    NSURL *userDir = [NSURL
        fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject];
    NSString *dirName = [NSString
        stringWithFormat:@"%@/%@%@", kGrowingTKResidentDirName, kGrowingTKDirCommonPrefix, @"event/toolskit.sqlite"];
    return [userDir URLByAppendingPathComponent:dirName].path;
}

+ (void)makeDirByFileName:(NSString *)filePath {
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

#pragma mark - Perform Block

- (void)performDatabaseBlock:(void (^)(GrowingTKFMDatabase *db, NSError *error))block {
    [self.db inDatabase:^(GrowingTKFMDatabase *db) {
        if (!db) {
            block(db, [self openErrorInDatabase:db]);
        } else {
            block(db, nil);
        }
    }];
}

- (void)performTransactionBlock:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error))block {
    [self.db inTransaction:^(GrowingTKFMDatabase *db, BOOL *rollback) {
        if (!db) {
            block(db, rollback, [self openErrorInDatabase:db]);
        } else {
            block(db, rollback, nil);
        }
    }];
}

#pragma mark - Error

- (NSError *)lastError {
    return self.databaseError;
}

- (NSError *)openErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:kGrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseOpenError
                           userInfo:@{NSLocalizedDescriptionKey: @"open database error"}];
}

- (NSError *)readErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:kGrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseReadError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)writeErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:kGrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseWriteError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)createDBErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:kGrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseCreateDBError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

@end
