//
//  GrowingTKDatabase+LaunchTime.m
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

#import "GrowingTKDatabase+LaunchTime.h"
#import "GrowingTKLaunchTimePersistence.h"
#import "GrowingTKFMDB.h"

@implementation GrowingTKDatabase (LaunchTime)

- (void)createLaunchTimeTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS launchtimetable("
                    @"id INTEGER PRIMARY KEY,"
                    @"key TEXT,"
                    @"type INTEGER NOT NULL,"
                    @"duration INTEGER NOT NULL,"
                    @"page TEXT,"
                    @"attributes TEXT,"
                    @"createAt INTEGER NOT NULL);";
    [self createTable:sql tableName:@"launchtimetable" indexs:@[@"id", @"key"]];
}

- (NSInteger)countOfLaunchTime {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM launchtimetable" values:nil error:nil];
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

- (NSArray<GrowingTKLaunchTimePersistence *> *)getAllLaunchTime {
    if (self.countOfLaunchTime == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingTKLaunchTimePersistence *> *record = [[NSMutableArray alloc] init];
    [self recordEnumerateKeysAndValuesUsingBlock:^(NSString *key,
                                                   int type,
                                                   double duration,
                                                   NSString *page,
                                                   NSString *attributes,
                                                   double createAt,
                                                   BOOL *stop) {
        GrowingTKLaunchTimePersistence *p = [[GrowingTKLaunchTimePersistence alloc] initWithUUID:key
                                                                                            type:type
                                                                                        duration:duration
                                                                                            page:page
                                                                                      attributes:attributes
                                                                                        createAt:createAt];
        [record addObject:p];
    }];

    return record.count != 0 ? record : nil;
}

- (BOOL)insertLaunchTime:(GrowingTKLaunchTimePersistence *)record {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"INSERT INTO launchtimetable(key,type,duration,page,attributes,createAt) VALUES(?,?,?,?,?,?)",
                                   record.recordUUID,
                                   @(record.type),
                                   @(record.duration),
                                   record.page,
                                   record.attributes,
                                   @(record.timestamp)];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)clearAllLaunchTime {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM launchtimetable" values:nil error:nil];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

#pragma mark - Private Methods

- (void)recordEnumerateKeysAndValuesUsingBlock:(void (^)(NSString *key,
                                                         int type,
                                                         double duration,
                                                         NSString *page,
                                                         NSString *attributes,
                                                         double createAt,
                                                         BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT * FROM launchtimetable ORDER BY id ASC" values:nil error:nil];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            int type = [set intForColumn:@"type"];
            double duration = [set doubleForColumn:@"duration"];
            NSString *page = [set stringForColumn:@"page"];
            NSString *attributes = [set stringForColumn:@"attributes"];
            double createAt = [set doubleForColumn:@"createAt"];
            block(key, type, duration, page, attributes, createAt, &stop);
        }

        [set close];
    }];
}

@end
