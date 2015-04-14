//
//  DatabaseManager.m
//  TypeGIF
//
//  Created by Andrew Rauh on 3/27/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "NSCountedSet+NSCountedSet_Additions.h"

static sqlite3 *database = nil;
static DatabaseManager *databaseInstance = nil;

@interface DatabaseManager ()

- (BOOL)initializeDatabase;
- (NSString *)readTokenFromFile;

@end

@implementation DatabaseManager

+(instancetype)createDatabaseInstance {
    if (!databaseInstance) {
        databaseInstance = [[super alloc]init];
        [databaseInstance initializeDatabase];
    }
    return databaseInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        //custom initialization
    }
    return self;
}

/* Creates database in documents directory. Bool indicates success */

-(BOOL)initializeDatabase {
    // Get the DB directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    _dataBasePath = [[NSString alloc] initWithString:
                     [docsDir stringByAppendingPathComponent: @"gif.db"]];
    
    NSLog(@"%@", _dataBasePath);
    
    //Create DB Tables
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _dataBasePath] == NO) {
        const char *dbpath = [_dataBasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK){
            char *errMsg;
            //Gif
            const char *sql_stmt =
            "create table if not exists GIF (photo_url text, location_url text, UNIQUE(photo_url))";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table a");
            }
            
            sql_stmt =
            "create table if not exists COLLECTION (collection_name text, photo_url text, UNIQUE(photo_url))";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table b");
            }

            sqlite3_close(database);
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }
    NSLog(@"created database");
    return isSuccess;
}

- (void) addGifToDatabaseWithIdentifier:(NSString*)identifier andPath:(NSString*)path{
    if (!_dataBasePath) return;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT OR REPLACE INTO GIF VALUES (?, ?)", identifier, path];
    }];

}

- (NSString*) _retrieveGifDataWithAssetURL:(NSString*) url {
    __block NSString *gifData = [[NSString alloc]init];
    
    if (!_dataBasePath) return nil;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *qs = [NSString stringWithFormat:@"select * from GIF where photo_url='%@'", url];
        
        FMResultSet *rs = [db executeQuery:qs];
        if (rs == nil) NSLog(@"result set nil");
        
        while ([rs next]) {
            gifData = [rs objectForColumnIndex:1];

        }
    }];
    
    return gifData;
}

- (void) addGifToCollection:(NSString *)collectionName and:(NSString *)photoUrl {
    NSLog(@"saving to %@", collectionName);
    
    if (!_dataBasePath) return;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO COLLECTION VALUES (?, ?)", collectionName, photoUrl];
        NSLog(@"*** INSERTING %@ \n INTO %@", photoUrl, collectionName);
    }];
}

- (NSArray*) photoUrlsForCollection:(NSString*) collectionName{
    NSMutableArray *photoUrls = [[NSMutableArray alloc]init];
    __block NSString *gifData = [[NSString alloc]init];
    
    if (!_dataBasePath) return nil;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *qs = [NSString stringWithFormat:@"select * from COLLECTION where collection_name='%@' and photo_url is not null", collectionName];
        
        FMResultSet *rs = [db executeQuery:qs];
        if (rs == nil) NSLog(@"result set nil");
        
        while ([rs next]) {
            gifData = [rs objectForColumnIndex:1];
            [photoUrls addObject:gifData];
        }
    }];
    return [NSArray arrayWithArray:photoUrls];
}



- (NSArray*) getAllCollections {
//    NSLog(@"was called");
    NSMutableArray *allCollections = [[NSMutableArray alloc]init];
    __block NSString *collectionName = [[NSString alloc]init];
    if (!_dataBasePath) return nil;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *qs = [NSString stringWithFormat:@"select collection_name from COLLECTION"];
        FMResultSet *rs = [db executeQuery:qs];
        if (rs == nil) NSLog(@"result set nil");
        while ([rs next]) {
            collectionName = [rs objectForColumnIndex:0];
            [allCollections addObject:collectionName];
        }
    }];
    NSArray *finalArray = [[NSSet setWithArray:allCollections] allObjects];
    return [NSArray arrayWithArray:finalArray];
}

- (void) addNewCollectionWithName:(NSString*) collectionName {
    if (!_dataBasePath) return;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT OR REPLACE INTO COLLECTION VALUES (?, ?)", collectionName, nil];
    }];
}

-(void) removeCollectionWithName:(NSString* ) collectionName {
    if (!_dataBasePath) return;
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *qs = [NSString stringWithFormat:@"DELETE * from COLLECTION where collection_name='%@'", collectionName];
        [db executeUpdate:qs];
    }];
}

@end
