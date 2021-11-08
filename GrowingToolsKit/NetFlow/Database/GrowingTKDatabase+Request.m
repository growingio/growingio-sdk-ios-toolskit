//
//  GrowingTKDatabase+Request.m
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

#import "GrowingTKDatabase+Request.h"
#import "GrowingTKFMDB.h"
#import "GrowingTKRequestPersistence.h"

static long long const kGrowingTKRequestsDatabaseExpirationTime = 86400000 * 30LL;

@implementation GrowingTKDatabase (Request)

#pragma mark - Public Methods

- (void)createRequestsTable {
    NSString *sql = @"create table if not exists requeststable("
                    @"id INTEGER PRIMARY KEY,"
                    @"key text,"
                    @"requestBody text,"
                    @"responseBody text,"
                    @"createAt INTEGER NOT NULL,"
                    @"jsonString text);";
    [self createTable:sql tableName:@"requeststable" indexs:@[@"id", @"key"]];
}

- (NSInteger)countOfRequests {
    __block NSInteger count = 0;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            count = -1;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"select count(*) from requeststable" values:nil error:nil];
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

- (NSArray<GrowingTKRequestPersistence *> *)getAllRequests {
    if (self.countOfRequests == 0) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<GrowingTKRequestPersistence *> *requests = [[NSMutableArray alloc] init];
    [self requestsEnumerateKeysAndValuesUsingBlock:^(NSString *key,
                                                     NSString *jsonString,
                                                     NSString *requestBody,
                                                     NSString *responseBody,
                                                     BOOL *stop) {
        GrowingTKRequestPersistence *request = [[GrowingTKRequestPersistence alloc] initWithRequestBody:requestBody
                                                                                           responseBody:responseBody
                                                                                             jsonString:jsonString];
        [requests addObject:request];
    }];

    return requests.count != 0 ? requests : nil;
}

- (BOOL)insertRequest:(GrowingTKRequestPersistence *)request {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result =
            [db executeUpdate:
                    @"insert into requeststable(key,requestBody,responseBody,createAt,jsonString) values(?,?,?,?,?)",
                    [NSString stringWithFormat:@"%f", request.startTimestamp],
                    request.requestBody,
                    request.responseBody,
                    @([[NSDate date] timeIntervalSince1970] * 1000LL),
                    request.rawJsonString];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)insertRequests:(NSArray<GrowingTKRequestPersistence *> *)requests {
    if (!requests || requests.count == 0) {
        return YES;
    }

    __block BOOL result = NO;
    [self performTransactionBlock:^(GrowingTKFMDatabase *db, BOOL *rollback, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        for (int i = 0; i < requests.count; i++) {
            GrowingTKRequestPersistence *request = requests[i];
            result = [db
                executeUpdate:
                    @"insert into requeststable(key,requestBody,responseBody,createAt,jsonString) values(?,?,?,?,?)",
                    [NSString stringWithFormat:@"%f", request.startTimestamp],
                    request.requestBody,
                    request.responseBody,
                    @([[NSDate date] timeIntervalSince1970] * 1000LL),
                    request.rawJsonString];

            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)deleteRequest:(NSString *)key {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from requeststable where key=?;", key];

        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)deleteRequests:(NSArray<NSString *> *)keys {
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
            result = [db executeUpdate:@"delete from requeststable where key=?;", key];
            if (!result) {
                self.databaseError = [self writeErrorInDatabase:db];
                break;
            }
        }
    }];

    return result;
}

- (BOOL)clearAllRequests {
    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from requeststable" values:nil error:nil];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

- (BOOL)cleanExpiredRequestIfNeeded {
    NSNumber *now = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000LL)];
    NSNumber *dayBefore = [NSNumber numberWithLongLong:(now.longLongValue - kGrowingTKRequestsDatabaseExpirationTime)];

    __block BOOL result = NO;
    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        result = [db executeUpdate:@"delete from requeststable where createAt<=?;", dayBefore];
        if (!result) {
            self.databaseError = [self writeErrorInDatabase:db];
        }
    }];

    return result;
}

#pragma mark - Private Methods

- (void)requestsEnumerateKeysAndValuesUsingBlock:
    (void (^)(NSString *key, NSString *jsonString, NSString *requestBody, NSString *responseBody, BOOL *stop))block {
    if (!block) {
        return;
    }

    [self performDatabaseBlock:^(GrowingTKFMDatabase *db, NSError *error) {
        if (error) {
            self.databaseError = error;
            return;
        }
        GrowingTKFMResultSet *set = [db executeQuery:@"select * from requeststable order by id asc"
                                              values:nil
                                               error:nil];
        if (!set) {
            self.databaseError = [self readErrorInDatabase:db];
            return;
        }

        BOOL stop = NO;
        while (!stop && [set next]) {
            NSString *key = [set stringForColumn:@"key"];
            NSString *jsonString = [set stringForColumn:@"jsonString"];
            NSString *requestBody = [set stringForColumn:@"requestBody"];
            NSString *responseBody = [set stringForColumn:@"responseBody"];
            block(key, jsonString, requestBody, responseBody, &stop);
        }

        [set close];
    }];
}

@end
