//
//  SQLiteManager.m
//  SQLiteTest2
//
//  Created by 相澤 隆志 on 2014/04/16.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>


@interface SQLiteManager ()

@property  sqlite3* sqlite;
@property (nonatomic, strong) NSString* dbFileName;
@property (nonatomic, strong) NSString* dbFilePath;
@property (nonatomic, strong) NSString* tableName;
@property  sqlite3_stmt *statement;
@end

@implementation SQLiteManager

//static SQLiteManager* gSQLiteManager;
static NSMutableArray* gFileNameArray;
+ (SQLiteManager*)sharedSQLiteManager:(NSString*)dbFileName
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gFileNameArray = [[NSMutableArray alloc] init];
        //gSQLiteManager = [[SQLiteManager alloc] init];
        //gSQLiteManager.dbFileName = @"testDB.sqlite3";
        //[gSQLiteManager createDB:gSQLiteManager.dbFileName];
    });
    
    for( NSDictionary* instance in gFileNameArray){
        if( [instance valueForKey:@"name"] == dbFileName ){
            return [instance valueForKey:@"instance"];
        }
    }
    SQLiteManager* sqlMngr = [[SQLiteManager alloc] init];
    NSDictionary* newInstance = @{@"name":dbFileName,@"instance":sqlMngr};
    [sqlMngr createDB:dbFileName];
    sqlMngr.dbFileName = dbFileName;
    [gFileNameArray addObject:newInstance];
    return sqlMngr;
    
    //return gSQLiteManager;
}

- (BOOL)openDB
{
    BOOL result = YES;
    int ret = sqlite3_open([_dbFilePath UTF8String], &_sqlite);
    if( ret != SQLITE_OK )
    {
        NSLog(@"DB Open error : %s",sqlite3_errmsg(_sqlite));
        result = NO;
    }
    return result;
}

- (BOOL)closeDB
{
    BOOL result = YES;
    int ret = sqlite3_close(_sqlite);
    if( ret != SQLITE_OK )
    {
        NSLog(@"DB Open error : %s",sqlite3_errmsg(_sqlite));
        result = NO;
    }else{
        _sqlite = nil;
    }
    return result;
}

// [
//      {"name":"nameString", "type:"TEXT"}
//      {"name":"nameString", "type:"integer"}
//      {"name":"nameString", "type:"double"}
//      {"name":"nameString", "type:"TEXT"}
//      {"name":"nameString", "type:"TEXT"}
// ]
- (BOOL)createTable:(NSString*)tableName  columns:(NSArray*)params
{
    BOOL result = YES;
    _tableName = tableName;
    NSMutableString* sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName ];
    for( NSDictionary* param in params ){
        NSString* columnName = [param valueForKey:@"name"];
        NSString* type = [param valueForKey:@"type"];
        [sql appendFormat:@"%@ %@, ",columnName, type];
    }
    NSMutableString *str = [NSMutableString stringWithString:[sql substringToIndex:(sql.length-2)]];
    [str appendString:@");"];
    //
    //str = [NSMutableString stringWithString: @"CREATE TABLE IF NOT EXISTS unkos (name TEXT)"];
    //
    NSLog(@"sql = %@",str);
    
    int ret = sqlite3_prepare_v2(_sqlite, [str UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK ){
        NSLog(@"sqlite3_prepare_v2 error");
        result = NO;
    }
    ret = sqlite3_step(_statement);
    /*
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_step error");
        NSLog(@"sqlite3_step : %s",sqlite3_errmsg(_sqlite));
        result = NO;
    }
    */
    ret = sqlite3_finalize(_statement);
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_finalize error");
        result = NO;
    }
    return result;
}

- (BOOL)insertObjectWithArray:(NSArray*)params
{
    return [self insert:params];
}
// {"name":"columnName2, "type":type, "value":val, "count":num}
- (BOOL)insertObject:(NSDictionary*)param, ...
{
    //BOOL result = YES;
    va_list arguments;
    va_start(arguments, param);
    NSDictionary* column = param;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:column];
    while ( param ) {
        param = va_arg(arguments, id);
        if(param == nil)
            break;
        column = param;
        [array addObject:column];
    }
    va_end(arguments);

    return [self insert:array];
/*
    NSMutableString* sql = [NSMutableString stringWithFormat:@"insert into %@ (",_tableName ];
    for( NSDictionary* param in array ){
        [sql appendFormat:@"%@ ,", [param valueForKey:@"name"]];
    }
    NSMutableString *str = [NSMutableString stringWithString:[sql substringToIndex:(sql.length-2)]];
    [str appendString:@") values ("];
    for( int i = 0; i < array.count; i ++ ){
        [str appendString:@"?,"];
    }
    NSMutableString* strSql =[NSMutableString stringWithString:[str substringToIndex:(str.length-1)]];
    [strSql appendString:@")"];
    NSLog(@"insert: sql = %@",strSql);
    
    int ret = sqlite3_prepare_v2(_sqlite, [strSql UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK){
        result = NO;
    }else{
        for ( int x = 1; x < array.count+1; ++x ) {
            sqlite3_reset(_statement);
            switch ([[array[x-1]valueForKeyPath:@"type" ] intValue]) {
                case TypeText:
                    ret = sqlite3_bind_text(_statement, x, [[array[x-1] valueForKey:@"value"] UTF8String], -1, SQLITE_STATIC);
                    break;
                case TypeInteger:
                    ret = sqlite3_bind_int(_statement, x, [[array[x-1] valueForKey:@"value"] intValue]);
                    break;
                case TypeReal:
                    ret = sqlite3_bind_double(_statement, x, [[array[x-1] valueForKey:@"value"] doubleValue]);
                    break;
                case TypeBLOB:
                    ret = sqlite3_bind_blob(_statement, x, (__bridge const void *)([array[x-1] valueForKey:@"value"]), [[array[x-1] valueForKey:@"count"] intValue], SQLITE_TRANSIENT);
                    break;
                default:
                    break;
            }
            if( ret != SQLITE_OK ){
                NSLog(@"sqlite bind error");
                result = NO;
            }
        }
        ret = sqlite3_step(_statement);
        ret = sqlite3_finalize(_statement);
        if( ret != SQLITE_OK ){
            NSLog(@"sqlite3_finalize error");
            result = NO;
        }
    }
    return result;
*/
}

//{"name":"columnName", "index":index, "type":type}
//{"name":"columnName", "index":index, "type":type}
//{"name":"columnName", "index":index, "type":type}
- (NSArray*)fetchResultOnSelect:(NSString*)selectString whereAndOrder:(NSString*)whereAndOrderString format:(NSArray*)formatResult
{
    NSMutableArray* resultsArray = [[NSMutableArray alloc] init];
    NSMutableString* sql;
    if( whereAndOrderString == nil )
    {
         sql = [NSMutableString stringWithFormat:@"%@ %@ ",selectString, _tableName];
    }else{
         sql = [NSMutableString stringWithFormat:@"%@ %@ %@",selectString, _tableName, whereAndOrderString ];
    }
    int ret = sqlite3_prepare_v2(_sqlite, [sql UTF8String], -1, &_statement, nil);
    if( ret == SQLITE_OK ){
        while (sqlite3_step(_statement) == SQLITE_ROW) {
            NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
            //for test
            int i = 0;
            for( NSDictionary* column in formatResult ){
                int index = [[column valueForKey:@"index"] intValue];
                int type = [[column valueForKey:@"type"] intValue];
                NSString* columnNameLabel = [column valueForKey:@"name"];
                switch (type) {
                    case TypeText:
                    {
                        // for test
                        if( i == 17 )
                        {
                            NSLog(@"test");
                        }
                        //
                        char * resultString = (char*)sqlite3_column_text(_statement, index);
                        NSString* str;
                        if( resultString == NULL ){
                            str = @"";
                        }else{
                            str = [NSString stringWithUTF8String:resultString];
                        }
                        [resultDictionary setObject:str forKey:columnNameLabel];
                        break;
                    }
                    case TypeInteger:
                    {
                        int resultInt = sqlite3_column_int(_statement, index);
                        [resultDictionary setObject:[NSNumber numberWithInt:resultInt] forKey:columnNameLabel];
                        break;
                    }
                    case TypeReal:
                    {
                        double resultDouble = sqlite3_column_double(_statement, index);
                        [resultDictionary setObject:[NSNumber numberWithDouble:resultDouble] forKey:columnNameLabel];
                        break;
                    }
                    case TypeBLOB:
                    {
                        void* resultData = (void*)sqlite3_column_blob(_statement, index);
                        int size = sqlite3_column_bytes(_statement, index);
                        [resultDictionary setObject:[NSData dataWithBytes:resultData length:size] forKey:columnNameLabel];
                        break;
                    }
                   default:
                        break;
                }
                i++;
            }
            [resultsArray addObject:resultDictionary];
        }
    }else{
        NSLog(@"sqlite3_prepare_v2 error");
    }
    return resultsArray;
}


- (BOOL)createDB:(NSString*)dbfileName
{
    BOOL result = YES;
    _dbFilePath = [self getDocumentDirectoryFilepath:dbfileName];
    NSLog(@"DB file: %@",_dbFilePath);
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = ([fileManager fileExistsAtPath:_dbFilePath isDirectory:&isDir] && !isDir);
    BOOL ret;
    if( fileExists == NO ){
        NSLog(@"File is not exist.");
        ret = [fileManager createFileAtPath:_dbFilePath contents:nil attributes:nil];
        if (!ret) {
            NSLog(@"createFileAtPath error File is not exist.");
            result = NO;
        }
    }else{
        NSLog(@"File is exist.");
    }
    return result;
}

-(BOOL)deleteObjectWhere:(NSString*)whereSqlString
{
    BOOL result = YES;
    NSString* sql;
    if( whereSqlString == nil ){
        sql = [NSString stringWithFormat:@"DELETE FROM %@",_tableName ];
    }else{
        sql = [NSString stringWithFormat:@"DELETE FROM %@ %@",_tableName, whereSqlString ];
    }
    int ret = sqlite3_prepare_v2(_sqlite, [sql UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK ){
        NSLog(@"sqlite3_prepare_v2 error");
        result = NO;
        return result;
    }
    sqlite3_step(_statement);
    ret = sqlite3_finalize(_statement);
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_finalize error");
        result = NO;
        return result;
    }
    return result;
}

- (BOOL)createIndex:(NSString*)name column:(NSString*)column
{
    BOOL result = YES;
    NSString* sql = [NSString stringWithFormat:@"create index %@ on %@(%@)",name,_tableName,column];
    int ret = sqlite3_prepare_v2(_sqlite, [sql UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK ){
        NSLog(@"sqlite3_prepare_v2 error");
        result = NO;
        return result;
    }
    sqlite3_step(_statement);
    ret = sqlite3_finalize(_statement);
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_finalize error");
        result = NO;
        return result;
    }
    return result;
}

- (NSString*)getDocumentDirectoryFilepath:(NSString*)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    
    NSString* dbPath = paths[0];
    NSString* dbFilePath = [dbPath stringByAppendingPathComponent:fileName];
    return dbFilePath;
}

- (BOOL)insert:(NSArray*)params
{
    BOOL result = YES;
    NSMutableString* sql = [NSMutableString stringWithFormat:@"insert into %@ (",_tableName ];
    for( NSDictionary* param in params ){
        [sql appendFormat:@"%@ ,", [param valueForKey:@"name"]];
    }
    NSMutableString *str = [NSMutableString stringWithString:[sql substringToIndex:(sql.length-2)]];
    [str appendString:@") values ("];
    for( int i = 0; i < params.count; i ++ ){
        [str appendString:@"?,"];
    }
    NSMutableString* strSql =[NSMutableString stringWithString:[str substringToIndex:(str.length-1)]];
    [strSql appendString:@")"];
    NSLog(@"insert: sql = %@",strSql);
    
    int ret = sqlite3_prepare_v2(_sqlite, [strSql UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK){
        result = NO;
    }else{
        for ( int x = 1; x < params.count+1; ++x ) {
            sqlite3_reset(_statement);
            switch ([[params[x-1]valueForKeyPath:@"type" ] intValue]) {
                case TypeText:
                    if(x==10){
                        NSLog(@"x=10");
                    }
                    ret = sqlite3_bind_text(_statement, x, [[params[x-1] valueForKey:@"value"] UTF8String], -1, SQLITE_STATIC);
                    break;
                case TypeInteger:
                    ret = sqlite3_bind_int(_statement, x, [[params[x-1] valueForKey:@"value"] intValue]);
                    break;
                case TypeReal:
                    ret = sqlite3_bind_double(_statement, x, [[params[x-1] valueForKey:@"value"] doubleValue]);
                    break;
                case TypeBLOB:
                    ret = sqlite3_bind_blob(_statement, x, (__bridge const void *)([params[x-1] valueForKey:@"value"]), [[params[x-1] valueForKey:@"count"] intValue], SQLITE_TRANSIENT);
                    break;
                default:
                    break;
            }
            if( ret != SQLITE_OK ){
                NSLog(@"sqlite bind error");
                result = NO;
            }
        }
        ret = sqlite3_step(_statement);
        /*
         if( ret != SQLITE_OK ){
         NSLog(@"sqlite3_step error");
         result = NO;
         }
         */
        ret = sqlite3_finalize(_statement);
        if( ret != SQLITE_OK ){
            NSLog(@"sqlite3_finalize error");
            result = NO;
        }
    }
    return result;
}


- (void)test
{
    // とりあえず、使用する物理ファイル名を決めちゃう
    NSString *dataFileName = @"unkolist.sqlite3";
    NSString *dataFileFullPath;
    
    // 1.【物理ファイルを準備します】
    
    // 使用可能なファイルパスを全て取得する
    NSArray *availablePats = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // 最初のものを使用する
    NSString *dir = [availablePats objectAtIndex:0];
    // ファイルマネージャを召還する
    NSFileManager *myFM = [NSFileManager defaultManager];
    // 物理ファイルって既にありますか？
    dataFileFullPath = [dir stringByAppendingPathComponent:dataFileName];
    BOOL fileExists = [myFM fileExistsAtPath:dataFileFullPath];
    // 無い場合はつくる
    if (! fileExists) {
        BOOL isSuccessfullyCreated = [myFM createFileAtPath:dataFileFullPath contents:nil attributes:nil];
        if (! isSuccessfullyCreated) {
            NSLog(@"新規ファイル作成に失敗しました=>%@", dataFileFullPath);
        }
    }
    
    // 2.【sqiteを開く】
    
    // FIXME: この書き方だとメモリリークする？
    sqlite3 *sqlax;
    // 開きます
    BOOL isSuccessfullyOpened = sqlite3_open([dataFileFullPath UTF8String], &sqlax);
    if (isSuccessfullyOpened != SQLITE_OK) {
        NSLog(@"sqlite開けませんでした！=> %s", sqlite3_errmsg(sqlax));
    }
    
    // 3.【queryとstatementを確保しとこう】
    NSString *query;
    sqlite3_stmt *statement;
    
    // 4.【sql文を実行していく】
    
    // CREATE IF NOT EXISTS
    query = @"CREATE TABLE IF NOT EXISTS unkos (name TEXT)";
    int ret = sqlite3_prepare_v2(sqlax, [query UTF8String], -1, &statement, nil);
    ret = sqlite3_step(statement);
    ret = sqlite3_finalize(statement);
    
    // INSERT
    NSString *name = [NSString stringWithFormat:@"%@%d",@"otiai",arc4random() % 99];
    query = [NSString stringWithFormat:@"INSERT INTO unkos VALUES(\"%@\")", name];
    sqlite3_prepare_v2(sqlax, [query UTF8String], -1, &statement, nil);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    // SELECT
    query = @"SELECT name FROM unkos";
    sqlite3_prepare_v2(sqlax, [query UTF8String], -1, &statement, nil);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *ownerNameChars = (char *) sqlite3_column_text(statement,0);
        NSLog(@"Found : %s", ownerNameChars);
    }
    sqlite3_finalize(statement);
    
    // 5.【sqlite閉じる】
    sqlite3_close(sqlax);
    
    // }}} ここまで書いた
    
}

@end
