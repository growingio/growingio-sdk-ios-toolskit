

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
#import "GrowingTKEventPersistence.h"

typedef NS_ENUM(NSInteger, GrowingTKDatabaseError) {
    GrowingTKDatabaseOpenError = 500,  ///打开数据库错误
    GrowingTKDatabaseWriteError,       ///数据库写入错误
    GrowingTKDatabaseReadError,        ///数据库读取错误
    GrowingTKDatabaseCreateDBError,    ///创建数据库错误
};

static long long const GrowingTKDatabaseExpirationTime = 86400000 * 30LL;
static NSString *const GrowingTKDatabaseErrorDomain = @"com.growing.toolskit.event.database.error";
static NSString *const kGrowingTKResidentDirName = @"com.growingio.core";
static NSString *const kGrowingTKDirCommonPrefix = @"com.growingio.";

@interface GrowingTKDatabase ()

@property (nonatomic, strong) GrowingTKFMDatabaseQueue *db;
@property (nonatomic, strong) NSError *databaseError;

@end

@implementation GrowingTKDatabase

#pragma mark - Init

+ (instancetype)databaseWithPath:(NSString *)path error:(NSError **)error {
    return [[self alloc] initWithFilePath:path error:error];
}

- (instancetype)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self makeDirByFileName:filePath];
        });

        _db = [GrowingTKFMDatabaseQueue databaseQueueWithPath:filePath];
    }

    if (![self initDB]) {
        *error = self.databaseError;
    }

    return self;
}

+ (NSString *)defaultPath {
    NSURL *userDir = [NSURL
        fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject];
    NSString *dirName = [NSString
        stringWithFormat:@"%@/%@%@", kGrowingTKResidentDirName, kGrowingTKDirCommonPrefix, @"event/toolskit.sqlite"];
    return [userDir URLByAppendingPathComponent:dirName].path;
}

#pragma mark - Public Methods

- (NSInteger)countOfEvents {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"select count(*) from eventstable" values:nil error:nil];
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

- (NSArray<GrowingTKEventPersistence *> *)getAllEvents {
    if (self.countOfEvents == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingTKEventPersistence *> *events = [[NSMutableArray alloc] init];
    [self enumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL isSend, BOOL *stop) {
        GrowingTKEventPersistence *event = [[GrowingTKEventPersistence alloc] initWithUUID:key
                                                                                 eventType:type
                                                                                jsonString:value
                                                                                    isSend:isSend];
        [events addObject:event];
    }];

    return events.count != 0 ? events : nil;
}

- (BOOL)insertEvent:(GrowingTKEventPersistence *)event {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"insert into eventstable(key,value,createAt,type,isSend) values(?,?,?,?,?)",
                                   event.eventUUID,
                                   event.rawJsonString,
                                   @([[NSDate date] timeIntervalSince1970] * 1000LL),
                                   event.eventType,
                                   @(0)];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)insertEvents:(NSArray<GrowingTKEventPersistence *> *)events {
    if (!events || events.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        for (int i = 0; i < events.count; i++) {
            GrowingTKEventPersistence *event = events[i];
            result = [db executeUpdate:@"insert into eventstable(key,value,createAt,type,isSend) values(?,?,?,?,?)",
                                       event.eventUUID,
                                       event.rawJsonString,
                                       @([[NSDate date] timeIntervalSince1970] * 1000LL),
                                       event.eventType,
                                       @(0)];

            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)updateEventDidSend:(NSString *)key {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"update eventstable set isSend=? where key=?;", @(1), key];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)deleteEvent:(NSString *)key {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from eventstable where key=?;", key];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)deleteEvents:(NSArray<NSString *> *)keys {
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
            result = [db executeUpdate:@"delete from eventstable where key=?;", key];
            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)clearAllEvents {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from eventstable" values:nil error:nil];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)cleanExpiredEventIfNeeded {
    NSNumber *now = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000LL)];
    NSNumber *dayBefore = [NSNumber numberWithLongLong:(now.longLongValue - GrowingTKDatabaseExpirationTime)];

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from eventstable where createAt<=?;", dayBefore];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (NSError *)lastError {
    return self.databaseError;
}

#pragma mark - Private Methods

- (BOOL)initDB {
    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }

        NSString *sql = @"create table if not exists eventstable("
                        @"id INTEGER PRIMARY KEY,"
                        @"key text,"
                        @"value text,"
                        @"createAt INTEGER NOT NULL,"
                        @"type text,"
                        @"isSend INTEGER);";
        NSString *sqlCreateIndexKey = @"create index if not exists eventstable_key_index on eventstable (key);";
        NSString *sqlCreateIndexId = @"create index if not exists eventstable_id_index on eventstable (id);";
        if (![db executeUpdate:sql]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndexKey]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }
        if (![db executeUpdate:sqlCreateIndexId]) {
            self.databaseError = [self createDBErrorInDatabase:db];
            return;
        }

        result = YES;
    }];

    if (result) {
        return [self vacuum];
    } else {
        return result;
    }
}

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
        result = [db executeUpdate:@"VACUUM eventstable"];
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

- (void)makeDirByFileName:(NSString *)filePath {
    [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

- (void)enumerateKeysAndValuesUsingBlock:
    (void (^)(NSString *key, NSString *value, NSString *type, BOOL isSend, BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"select * from eventstable order by id asc" values:nil error:nil];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            NSString *value = [set stringForColumn:@"value"];
            NSString *type = [set stringForColumn:@"type"];
            BOOL isSend = [set boolForColumn:@"isSend"];
            block(key, value, type, isSend, &stop);
        }

        [set close];
    }];
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

- (NSError *)openErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:GrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseOpenError
                           userInfo:@{NSLocalizedDescriptionKey: @"open database error"}];
}

- (NSError *)readErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:GrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseReadError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)writeErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:GrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseWriteError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

- (NSError *)createDBErrorInDatabase:(GrowingTKFMDatabase *)db {
    return [NSError errorWithDomain:GrowingTKDatabaseErrorDomain
                               code:GrowingTKDatabaseCreateDBError
                           userInfo:@{NSLocalizedDescriptionKey: ([db lastErrorMessage] ?: @"")}];
}

@end
