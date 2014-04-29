//
//  SQLiteManager.h
//  SQLiteTest2
//
//  Created by 相澤 隆志 on 2014/04/16.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TypeText        (1)
#define TypeInteger     (2)
#define TypeReal        (3)
#define TypeBLOB        (4)

@interface SQLiteManager : NSObject

+ (SQLiteManager*)sharedSQLiteManager:(NSString*)dbFileName;
- (BOOL)createDB:(NSString*)dbfileName;
- (BOOL)openDB;
- (BOOL)closeDB;
- (BOOL)createTable:(NSString*)tableName  columns:(NSArray*)params;
- (BOOL)insertObject:(NSDictionary*)param, ...;
- (BOOL)insertObjectWithArray:(NSArray*)params;
- (NSArray*)fetchResultOnSelect:(NSString*)selectString whereAndOrder:(NSString*)whereAndOrderString format:(NSArray*)formatResult;
-(BOOL)deleteObjectWhere:(NSString*)whereSqlString;
- (BOOL)createIndex:(NSString*)name column:(NSString*)column;

- (void)test;

@end
