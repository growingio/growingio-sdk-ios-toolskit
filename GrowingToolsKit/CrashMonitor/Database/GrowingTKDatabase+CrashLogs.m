//
//  GrowingTKDatabase+CrashLogs.m
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

#import "GrowingTKDatabase+CrashLogs.h"
#import "GrowingTKCrashLogsPersistence.h"
#import "GrowingTKFMDB.h"

@implementation GrowingTKDatabase (CrashLogs)

#pragma mark - Public Methods

- (void)createCrashLogsTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS crashlogstable("
                    @"id INTEGER PRIMARY KEY,"
                    @"key TEXT,"
                    @"rawReport TEXT,"
                    @"appleFmt TEXT,"
                    @"createAt INTEGER NOT NULL);";
    [self createTable:sql tableName:@"crashlogstable" indexs:@[@"id", @"key"]];
}

- (NSInteger)countOfCrashLogs {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM crashlogstable" values:nil error:nil];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            count = -1;
            return;
        }

        if ([set next]) {
            count = (NSUInteger)[set longLongIntForColumnIndex:0];
        }

        [set close];
    }];

    return count;
}

- (NSArray<GrowingTKCrashLogsPersistence *> *)getAllCrashLogs {
    if (self.countOfCrashLogs == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingTKCrashLogsPersistence *> *crashLogs = [[NSMutableArray alloc] init];
    [self crashLogsEnumerateKeysAndValuesUsingBlock:^(NSString *key,
                                                      NSString *rawReport,
                                                      NSString *appleFmt,
                                                      BOOL *stop) {
        GrowingTKCrashLogsPersistence *p = [[GrowingTKCrashLogsPersistence alloc] initWithUUID:key
                                                                                     rawReport:rawReport
                                                                                      appleFmt:appleFmt];
        [crashLogs addObject:p];
    }];

    return crashLogs.count != 0 ? crashLogs : nil;
}

- (BOOL)insertCrashLog:(GrowingTKCrashLogsPersistence *)crashLog {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"INSERT INTO crashlogstable(key,rawReport,appleFmt,createAt) VALUES(?,?,?,?)",
                                   crashLog.crashUUID,
                                   crashLog.rawReport,
                                   crashLog.appleFmt,
                                   @([[NSDate date] timeIntervalSince1970] * 1000LL)];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)insertCrashLogs:(NSArray<GrowingTKCrashLogsPersistence *> *)crashLogs {
    if (!crashLogs || crashLogs.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        for (int i = 0; i < crashLogs.count; i++) {
            GrowingTKCrashLogsPersistence *crashLog = crashLogs[i];
            result = [db executeUpdate:@"INSERT INTO crashlogstable(key,rawReport,appleFmt,createAt) VALUES(?,?,?,?)",
                                       crashLog.crashUUID,
                                       crashLog.rawReport,
                                       crashLog.appleFmt,
                                       @([[NSDate date] timeIntervalSince1970] * 1000LL)];

            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)deleteCrashLog:(NSString *)key {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM crashlogstable WHERE key=?;", key];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)deleteCrashLogs:(NSArray<NSString *> *)keys {
    if (!keys || keys.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        for (NSString *key in keys) {
            result = [db executeUpdate:@"DELETE FROM crashlogstable WHERE key=?;", key];
            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)clearAllCrashLogs {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM crashlogstable" values:nil error:nil];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

#pragma mark - Private Methods

- (void)crashLogsEnumerateKeysAndValuesUsingBlock:(void (^)(NSString *key,
                                                            NSString *rawReport,
                                                            NSString *appleFmt,
                                                            BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT * FROM crashlogstable ORDER BY id ASC" values:nil error:nil];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            NSString *rawReport = [set stringForColumn:@"rawReport"];
            NSString *appleFmt = [set stringForColumn:@"appleFmt"];
            block(key, rawReport, appleFmt, &stop);
        }

        [set close];
    }];
}

@end
