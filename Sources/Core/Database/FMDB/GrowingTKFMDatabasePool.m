// Copyright (c) 2008-2014 Flying Meat Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  GrowingTKFMDatabasePool.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/13.
//  Copyright (C) 2020 Beijing Yishu Technology Co., Ltd.
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


#import "GrowingTKFMDatabasePool.h"
#import "GrowingTKFMDatabase.h"

@interface GrowingTKFMDatabasePool()

- (void)pushDatabaseBackInPool:(GrowingTKFMDatabase*)db;
- (GrowingTKFMDatabase*)db;

@end


@implementation GrowingTKFMDatabasePool
@synthesize path=_path;
@synthesize delegate=_delegate;
@synthesize maximumNumberOfDatabasesToCreate=_maximumNumberOfDatabasesToCreate;
@synthesize openFlags=_openFlags;


+ (instancetype)databasePoolWithPath:(NSString*)aPath {
    return GrowingTKFMDBReturnAutoreleased([[self alloc] initWithPath:aPath]);
}

+ (instancetype)databasePoolWithPath:(NSString*)aPath flags:(int)openFlags {
    return GrowingTKFMDBReturnAutoreleased([[self alloc] initWithPath:aPath flags:openFlags]);
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags {
    
    self = [super init];
    
    if (self != nil) {
        _path               = [aPath copy];
        _lockQueue          = dispatch_queue_create([[NSString stringWithFormat:@"GrowingTKFMDB.%@", self] UTF8String], NULL);
        _databaseInPool     = GrowingTKFMDBReturnRetained([NSMutableArray array]);
        _databaseOutPool    = GrowingTKFMDBReturnRetained([NSMutableArray array]);
        _openFlags          = openFlags;
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString*)aPath
{
    // default flags for sqlite3_open
    return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (instancetype)init {
    return [self initWithPath:nil];
}


- (void)dealloc {
    
    _delegate = 0x00;
    GrowingTKFMDBRelease(_path);
    GrowingTKFMDBRelease(_databaseInPool);
    GrowingTKFMDBRelease(_databaseOutPool);
    
    if (_lockQueue) {
        GrowingTKFMDBDispatchQueueRelease(_lockQueue);
        _lockQueue = 0x00;
    }
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}


- (void)executeLocked:(void (^)(void))aBlock {
    dispatch_sync(_lockQueue, aBlock);
}

- (void)pushDatabaseBackInPool:(GrowingTKFMDatabase*)db {
    
    if (!db) { // db can be null if we set an upper bound on the # of databases to create.
        return;
    }
    
    [self executeLocked:^() {
        
        if ([self->_databaseInPool containsObject:db]) {
            [[NSException exceptionWithName:@"Database already in pool" reason:@"The FMG3Database being put back into the pool is already present in the pool" userInfo:nil] raise];
        }
        
        [self->_databaseInPool addObject:db];
        [self->_databaseOutPool removeObject:db];
        
    }];
}

- (GrowingTKFMDatabase*)db {
    
    __block GrowingTKFMDatabase *db;
    
    
    [self executeLocked:^() {
        db = [self->_databaseInPool lastObject];
        
        BOOL shouldNotifyDelegate = NO;
        
        if (db) {
            [self->_databaseOutPool addObject:db];
            [self->_databaseInPool removeLastObject];
        }
        else {
            
            if (self->_maximumNumberOfDatabasesToCreate) {
                NSUInteger currentCount = [self->_databaseOutPool count] + [self->_databaseInPool count];
                
                if (currentCount >= self->_maximumNumberOfDatabasesToCreate) {
                    NSLog(@"Maximum number of databases (%ld) has already been reached!", (long)currentCount);
                    return;
                }
            }
            
            db = [GrowingTKFMDatabase databaseWithPath:self->_path];
            shouldNotifyDelegate = YES;
        }
        
        //This ensures that the db is opened before returning
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [db openWithFlags:self->_openFlags];
#else
        BOOL success = [db open];
#endif
        if (success) {
            if ([self->_delegate respondsToSelector:@selector(databasePool:shouldAddDatabaseToPool:)] && ![self->_delegate databasePool:self shouldAddDatabaseToPool:db]) {
                [db close];
                db = 0x00;
            }
            else {
                //It should not get added in the pool twice if lastObject was found
                if (![self->_databaseOutPool containsObject:db]) {
                    [self->_databaseOutPool addObject:db];
                    
                    if (shouldNotifyDelegate && [self->_delegate respondsToSelector:@selector(databasePool:didAddDatabase:)]) {
                        [self->_delegate databasePool:self didAddDatabase:db];
                    }
                }
            }
        }
        else {
            NSLog(@"Could not open up the database at path %@", self->_path);
            db = 0x00;
        }
    }];
    
    return db;
}

- (NSUInteger)countOfCheckedInDatabases {
    
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [self->_databaseInPool count];
    }];
    
    return count;
}

- (NSUInteger)countOfCheckedOutDatabases {
    
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [self->_databaseOutPool count];
    }];
    
    return count;
}

- (NSUInteger)countOfOpenDatabases {
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [self->_databaseOutPool count] + [self->_databaseInPool count];
    }];
    
    return count;
}

- (void)releaseAllDatabases {
    [self executeLocked:^() {
        [self->_databaseOutPool removeAllObjects];
        [self->_databaseInPool removeAllObjects];
    }];
}

- (void)inDatabase:(void (^)(GrowingTKFMDatabase *db))block {
    
    GrowingTKFMDatabase *db = [self db];
    
    block(db);
    
    [self pushDatabaseBackInPool:db];
}

- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block {
    
    BOOL shouldRollback = NO;
    
    GrowingTKFMDatabase *db = [self db];
    
    if (useDeferred) {
        [db beginDeferredTransaction];
    }
    else {
        [db beginTransaction];
    }
    
    
    block(db, &shouldRollback);
    
    if (shouldRollback) {
        [db rollback];
    }
    else {
        [db commit];
    }
    
    [self pushDatabaseBackInPool:db];
}

- (void)inDeferredTransaction:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)inTransaction:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}
#if SQLITE_VERSION_NUMBER >= 3007000
- (NSError*)inSavePoint:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block {
    
    static unsigned long savePointIdx = 0;
    
    NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
    
    BOOL shouldRollback = NO;
    
    GrowingTKFMDatabase *db = [self db];
    
    NSError *err = 0x00;
    
    if (![db startSavePointWithName:name error:&err]) {
        [self pushDatabaseBackInPool:db];
        return err;
    }
    
    block(db, &shouldRollback);
    
    if (shouldRollback) {
        // We need to rollback and release this savepoint to remove it
        [db rollbackToSavePointWithName:name error:&err];
    }
    [db releaseSavePointWithName:name error:&err];
    
    [self pushDatabaseBackInPool:db];
    
    return err;
}
#endif

@end
