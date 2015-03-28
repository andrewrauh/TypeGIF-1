//
//  DatabaseManager.h
//  TypeGIF
//
//  Created by Andrew Rauh on 3/27/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"


@interface DatabaseManager : NSObject {
    NSString *_dataBasePath;
}

+(instancetype)createDatabaseInstance;

- (void) addGifToDatabaseWithIdentifier:(NSString*)identifier andPath:(NSString*)url;
- (NSString*) getPhotoURLForIdentifier:(NSString*)identifier;




@end
