//
//  FactlDataAccess.m
//  Factl
//
//  Created by anshaggarwal on 7/15/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "FactlDataAccess.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
//#import "DbHistory.h"

@implementation FactlDataAccess

+ (id)sharedFactlDbAccess
{
    static FactlDataAccess *sharedFactlDbAccess = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFactlDbAccess = [[self alloc] init];
    });
    return sharedFactlDbAccess;
}

+(NSString *)getDatabasePath
{
    NSString *databasePath = [(AppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
    //NSLog(@"%@", databasePath);
    
    return databasePath;
}

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(BOOL)storeName:(NSString *)first_name
        lastName:(NSString *)last_name
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"INSERT INTO user_data (first_name, last_name) VALUES (?, ?);",
                     [NSString stringWithString:first_name],
                     [NSString stringWithString:last_name], nil];
    
    [db close];
    return success;
}

-(NSString *)getName
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM user_data"];
    FMResultSet *results = [db executeQuery:query];
    NSString *name = @"";
    while([results next])
    {
        name = [NSString stringWithFormat:@"%@ %@", [results stringForColumn:@"first_name"], [results stringForColumn:@"last_name"]];
    }
    return name;
}


-(NSMutableArray *)getAllFacts
{
    NSMutableArray *facts = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM fact_data"];
    FMResultSet *results = [db executeQuery:query];
    
    while([results next])
    {
        SingleFact *fact = [[SingleFact alloc] init];
        
        fact.fact_id = [results intForColumn:@"fact_id"];
        fact.title = [results stringForColumn:@"title"];
        fact.source = [results stringForColumn:@"source"];
        fact.fact = [results stringForColumn:@"fact"];
        fact.picFilePath = [results stringForColumn:@"pic_file_path"];
        fact.likes = [results intForColumn:@"likes"];
        fact.comments = [results intForColumn:@"comments"];
        fact.is_favorite = [results intForColumn:@"is_favorite"];
        fact.like_synced = [results intForColumn:@"like_synced"];
        fact.modifiedDate = [results longForColumn:@"date_modified"];
        fact.createdDate = [results longForColumn:@"date_created"];
        fact.receivedDate = [results longForColumn:@"date_received"];
        
        [facts addObject:fact];
    }
    
    [db close];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"receivedDate" ascending:NO];
    [facts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    return facts;
}

-(BOOL)insertFact:(SingleFact *)fact
{
    NSTimeInterval timestamp = [[NSDate date]timeIntervalSince1970];
    if(!fact.createdDate)
    {
        fact.createdDate = timestamp;
    }
    if(!fact.modifiedDate)
    {
        fact.modifiedDate = timestamp;
    }
    if(!fact.receivedDate)
    {
        fact.receivedDate = timestamp;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];

    BOOL success =  [db executeUpdate:@"INSERT INTO fact_data (fact_id, date_created, date_modified, title, source, pic_file_path, fact, comments, likes, is_favorite, like_synced, date_received) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
                     [NSNumber numberWithInteger:fact.fact_id],
                     [NSNumber numberWithInteger:fact.createdDate],
                     [NSNumber numberWithInteger:fact.modifiedDate],
                     fact.title,
                     fact.source,
                     fact.picFilePath,
                     fact.fact,
                     [NSNumber numberWithInteger:fact.comments],
                     [NSNumber numberWithInteger:fact.likes],
                     [NSNumber numberWithInteger:fact.is_favorite],
                     [NSNumber numberWithInteger:1],
                     [NSNumber numberWithInteger:fact.receivedDate],
                     nil];
    
    [db close];
    return success;
}

-(BOOL)newCommentCount:(NSInteger)count forFact:(NSInteger)fact_id
{
    NSTimeInterval timestamp = [[NSDate date]timeIntervalSince1970];
    long modifiedDate = timestamp;
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"UPDATE fact_data SET comments = ?, date_modified = ? WHERE fact_id = ?",
                     [NSNumber numberWithInteger:count],
                     [NSNumber numberWithLong:modifiedDate],
                     [NSNumber numberWithInteger:fact_id], nil];
    
    [db close];
    return success;
}

-(BOOL)insertComment:(SingleComment *)com
{
    NSTimeInterval timestamp = [[NSDate date]timeIntervalSince1970];
    if(!com.createdDate)
    {
        com.createdDate = timestamp;
    }
    if(!com.modifiedDate)
    {
        com.modifiedDate = timestamp;
    }
    
    NSString *unique_identifer = [NSString stringWithFormat:@"%lu%@", (unsigned long)com.createdDate, com.author_id];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"INSERT OR IGNORE INTO comments (comment_by_user_name, comment, fact_id, date_created, date_modified, comment_by_user_id, synced, unique_identifier) VALUES (?, ?, ?, ?, ?, ?, ?, ?);",
                     com.author,
                     com.comment,
                     [NSNumber numberWithInteger:com.fact_id],
                     [NSNumber numberWithLong:com.createdDate],
                     [NSNumber numberWithLong:com.modifiedDate],
                     com.author_id,
                     [NSNumber numberWithInteger:com.synced],
                     unique_identifer, nil];
    
    [db close];
    return success;
}

-(BOOL)updateComment:(SingleComment *)com
{
    NSTimeInterval timestamp = [[NSDate date]timeIntervalSince1970];
    com.modifiedDate = timestamp;
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"UPDATE comments SET comment = ?, date_modified = ?, synced = ? WHERE id = ?",
                     com.comment,
                     [NSNumber numberWithLong:com.modifiedDate],
                     [NSNumber numberWithInteger:com.synced],
                     [NSNumber numberWithInteger:com.Id]];
    
    [db close];
    return success;

}

-(BOOL)clearFactDataTable
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    BOOL success =  [db executeUpdate:@"DELETE FROM fact_data"];
    
    [db close];
    
    return success;
}

-(BOOL)DoesFactExistsInDb:(NSInteger)fact_id
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    BOOL success = false;
    [db open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM fact_data WHERE fact_id = %ld", (long)fact_id];
    FMResultSet *results = [db executeQuery:query];
    while([results next])
    {
        success = true;
        break;
    }
    [db close];
    
    return success;
}

-(BOOL)clearCommentsTable
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    BOOL success =  [db executeUpdate:@"DELETE FROM comments"];
    
    [db close];
    
    return success;
}

-(BOOL)clearCommentsForFact:(NSInteger)fact_id
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    BOOL success =  [db executeUpdate:@"DELETE FROM comments WHERE fact_id = ?", [NSNumber numberWithInteger:fact_id]];
    
    [db close];
    
    return success;
}

-(NSMutableArray *)getAllCommentsForFact:(NSInteger)fact_id
{
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM comments WHERE fact_id = %ld ORDER BY (date_created) DESC", (long)fact_id];
    FMResultSet *results = [db executeQuery:query];
    
    while([results next])
    {
        SingleComment *com = [[SingleComment alloc] init];
        
        com.Id = [results intForColumn:@"id"];
        com.fact_id = [results intForColumn:@"fact_id"];
        com.author = [results stringForColumn:@"comment_by_user_name"];
        com.comment = [results stringForColumn:@"comment"];
        com.modifiedDate = [results longForColumn:@"date_modified"];
        com.createdDate = [results longForColumn:@"date_created"];
        com.synced = [results intForColumn:@"synced"];
        
        [comments addObject:com];
    }
    
    [db close];
    
    return comments;
}

-(NSMutableArray *)getTenCommentsForFact:(NSInteger)fact_id offsetNumber:(NSInteger)offset
{
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    
    [db open];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM comments WHERE fact_id = %ld ORDER BY (date_created) DESC LIMIT 10 OFFSET %ld", (long)fact_id, (long)offset];
    FMResultSet *results = [db executeQuery:query];
    
    while([results next])
    {
        SingleComment *com = [[SingleComment alloc] init];
        
        com.Id = [results intForColumn:@"id"];
        com.fact_id = [results intForColumn:@"fact_id"];
        com.author = [results stringForColumn:@"comment_by_user_name"];
        com.comment = [results stringForColumn:@"comment"];
        com.modifiedDate = [results longForColumn:@"date_modified"];
        com.createdDate = [results longForColumn:@"date_created"];
        com.synced = [results intForColumn:@"synced"];
        
        [comments addObject:com];
    }
    
    [db close];
    
    return comments;
}

-(BOOL)updateLike:(NSInteger)liked forFact:(NSInteger)fact_id withNewLikeCount:(NSInteger)likeCount
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"UPDATE fact_data SET is_favorite = ?, likes = ? WHERE fact_id = ?",
                     [NSNumber numberWithInteger:liked],
                     [NSNumber numberWithInteger:likeCount],
                     [NSNumber numberWithInteger:fact_id], nil];
    [db close];
    
    return success;
}

-(BOOL)updateLikeSync:(NSInteger)sync forFact:(NSInteger)fact_id
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"UPDATE fact_data SET like_synced = ? WHERE fact_id = ?",
                     [NSNumber numberWithInteger:sync],
                     [NSNumber numberWithInteger:fact_id], nil];
    [db close];
    
    return success;
}

-(BOOL)updateFact:(SingleFact *)fact
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    BOOL success =  [db executeUpdate:@"UPDATE fact_data SET likes = ?, comments = ?, pic_file_path = ?, is_favorite = ?  WHERE fact_id = ?",
                     [NSNumber numberWithInteger:fact.likes],
                     [NSNumber numberWithInteger:fact.comments],
                     fact.picFilePath,
                     [NSNumber numberWithInteger:fact.is_favorite],
                     [NSNumber numberWithInteger:fact.fact_id],
                     nil];
    [db close];
    
    return success;
}

-(int)getLikeStatusForFact:(NSInteger)fact_id
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FactlDataAccess getDatabasePath]];
    [db open];
    
    int liked = 0;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM fact_data WHERE fact_id = %ld", (long)fact_id];
    FMResultSet *results = [db executeQuery:query];
    while([results next])
    {
        liked = [results intForColumn:@"is_favorite"];
    }
    
    [db close];
    return liked;
}


@end
