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
//  GrowingTKFMDatabasePool.h
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


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class GrowingTKFMDatabase;

/** Pool of `<FMG3Database>` objects.

 ### See also
 
 - `<GrowingTKFMDatabaseQueue>`
 - `<FMG3Database>`

 @warning Before using `GrowingTKFMDatabasePool`, please consider using `<GrowingTKFMDatabaseQueue>` instead.

 If you really really really know what you're doing and `GrowingTKFMDatabasePool` is what
 you really really need (ie, you're using a read only database), OK you can use
 it.  But just be careful not to deadlock!

 For an example on deadlocking, search for:
 `ONLY_USE_THE_POOL_IF_YOU_ARE_DOING_READS_OTHERWISE_YOULL_DEADLOCK_USE_GrowingTKFMDatabaseQueue_INSTEAD`
 in the main.m file.
 */

@interface GrowingTKFMDatabasePool : NSObject {
    NSString            *_path;
    
    dispatch_queue_t    _lockQueue;
    
    NSMutableArray      *_databaseInPool;
    NSMutableArray      *_databaseOutPool;
    
    __unsafe_unretained id _delegate;
    
    NSUInteger          _maximumNumberOfDatabasesToCreate;
    int                 _openFlags;
}

/** Database path */

@property (atomic, retain) NSString *path;

/** Delegate object */

@property (atomic, assign) id delegate;

/** Maximum number of databases to create */

@property (atomic, assign) NSUInteger maximumNumberOfDatabasesToCreate;

/** Open flags */

@property (atomic, readonly) int openFlags;


///---------------------
/// @name Initialization
///---------------------

/** Create pool using path.

 @param aPath The file path of the database.

 @return The `GrowingTKFMDatabasePool` object. `nil` on error.
 */

+ (instancetype)databasePoolWithPath:(NSString*)aPath;

/** Create pool using path and specified flags

 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database

 @return The `GrowingTKFMDatabasePool` object. `nil` on error.
 */

+ (instancetype)databasePoolWithPath:(NSString*)aPath flags:(int)openFlags;

/** Create pool using path.

 @param aPath The file path of the database.

 @return The `GrowingTKFMDatabasePool` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath;

/** Create pool using path and specified flags.

 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database

 @return The `GrowingTKFMDatabasePool` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags;

///------------------------------------------------
/// @name Keeping track of checked in/out databases
///------------------------------------------------

/** Number of checked-in databases in pool
 
 @returns Number of databases
 */

- (NSUInteger)countOfCheckedInDatabases;

/** Number of checked-out databases in pool

 @returns Number of databases
 */

- (NSUInteger)countOfCheckedOutDatabases;

/** Total number of databases in pool

 @returns Number of databases
 */

- (NSUInteger)countOfOpenDatabases;

/** Release all databases in pool */

- (void)releaseAllDatabases;

///------------------------------------------
/// @name Perform database operations in pool
///------------------------------------------

/** Synchronously perform database operations in pool.

 @param block The code to be run on the `GrowingTKFMDatabasePool` pool.
 */

- (void)inDatabase:(void (^)(GrowingTKFMDatabase *db))block;

/** Synchronously perform database operations in pool using transaction.

 @param block The code to be run on the `GrowingTKFMDatabasePool` pool.
 */

- (void)inTransaction:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations in pool using deferred transaction.

 @param block The code to be run on the `GrowingTKFMDatabasePool` pool.
 */

- (void)inDeferredTransaction:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block;

#if SQLITE_VERSION_NUMBER >= 3007000

/** Synchronously perform database operations in pool using save point.

 @param block The code to be run on the `GrowingTKFMDatabasePool` pool.
 
 @return `NSError` object if error; `nil` if successful.

 @warning You can not nest these, since calling it will pull another database out of the pool and you'll get a deadlock. If you need to nest, use `<[FMG3Database startSavePointWithName:error:]>` instead.
*/

- (NSError*)inSavePoint:(void (^)(GrowingTKFMDatabase *db, BOOL *rollback))block;
#endif

@end


/** GrowingTKFMDatabasePool delegate category
 
 This is a category that defines the protocol for the GrowingTKFMDatabasePool delegate
 */

@interface NSObject (GrowingTKFMDatabasePoolDelegate)

/** Asks the delegate whether database should be added to the pool. 
 
 @param pool     The `GrowingTKFMDatabasePool` object.
 @param database The `FMG3Database` object.
 
 @return `YES` if it should add database to pool; `NO` if not.
 
 */

- (BOOL)databasePool:(GrowingTKFMDatabasePool*)pool shouldAddDatabaseToPool:(GrowingTKFMDatabase*)database;

/** Tells the delegate that database was added to the pool.
 
 @param pool     The `GrowingTKFMDatabasePool` object.
 @param database The `FMG3Database` object.

 */

- (void)databasePool:(GrowingTKFMDatabasePool*)pool didAddDatabase:(GrowingTKFMDatabase*)database;

@end

