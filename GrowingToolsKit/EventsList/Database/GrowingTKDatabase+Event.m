//
//  GrowingTKDatabase+Event.m
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

#import "GrowingTKDatabase+Event.h"
#import "GrowingTKFMDB.h"
#import "GrowingTKEventPersistence.h"

static long long const kGrowingTKEventsDatabaseExpirationTime = 86400000 * 30LL;

@implementation GrowingTKDatabase (Event)

#pragma mark - Public Methods

- (void)createEventsTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS eventstable("
                    @"id INTEGER PRIMARY KEY,"
                    @"key TEXT,"
                    @"value TEXT,"
                    @"createAt INTEGER NOT NULL,"
                    @"type TEXT,"
                    @"isSend INTEGER);";
    [self createTable:sql tableName:@"eventstable" indexs:@[@"id", @"key"]];
}

- (NSInteger)countOfEvents {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM eventstable" values:nil error:nil];
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
    [self eventsEnumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL isSend, BOOL *stop) {
        GrowingTKEventPersistence *event = [[GrowingTKEventPersistence alloc] initWithUUID:key
                                                                                 eventType:type
                                                                                jsonString:value
                                                                                    isSend:isSend];
        [events addObject:event];
    }];

    return events.count != 0 ? events : nil;
}

- (NSArray<GrowingTKEventPersistence *> *)getEventsByEventTypes:(NSArray <NSString *>*)eventTypes {
    if (self.countOfEvents == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingTKEventPersistence *> *events = [[NSMutableArray alloc] init];
    [self eventsEnumerateKeysAndValuesUsingBlock:^(NSString *key, NSString *value, NSString *type, BOOL isSend, BOOL *stop) {
        BOOL contain = NO;
        for (NSString *eventType in eventTypes) {
            if ([eventType.lowercaseString isEqualToString:type.lowercaseString]) {
                contain = YES;
                break;
            }
        }
        if (!contain) {
            return;
        }
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
        result = [db executeUpdate:@"INSERT INTO eventstable(key,value,createAt,type,isSend) VALUES(?,?,?,?,?)",
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
            result = [db executeUpdate:@"INSERT INTO eventstable(key,value,createAt,type,isSend) VALUES(?,?,?,?,?)",
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
        result = [db executeUpdate:@"UPDATE eventstable SET isSend=? WHERE key=?;", @(1), key];

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
        result = [db executeUpdate:@"DELETE FROM eventstable WHERE key=?;", key];

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
            result = [db executeUpdate:@"DELETE FROM eventstable WHERE key=?;", key];
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
        result = [db executeUpdate:@"DELETE FROM eventstable" values:nil error:nil];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)cleanExpiredEventIfNeeded {
    NSNumber *now = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000LL)];
    NSNumber *dayBefore = [NSNumber numberWithLongLong:(now.longLongValue - kGrowingTKEventsDatabaseExpirationTime)];

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"DELETE FROM eventstable WHERE createAt<=?;", dayBefore];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

#pragma mark - Private Methods

- (void)eventsEnumerateKeysAndValuesUsingBlock:
    (void (^)(NSString *key, NSString *value, NSString *type, BOOL isSend, BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"SELECT * FROM eventstable ORDER BY id ASC" values:nil error:nil];
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

@end
