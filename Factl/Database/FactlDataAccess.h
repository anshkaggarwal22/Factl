//
//  FactlDataAccess.h
//  Factl
//
//  Created by anshaggarwal on 7/15/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleFact.h"
#import "SingleComment.h"

@interface FactlDataAccess : NSObject

+(NSString *)getDatabasePath;
+(id)sharedFactlDbAccess;


-(BOOL)storeName:(NSString *)first_name lastName:(NSString *)last_name;
-(NSString *)getName;
-(NSMutableArray *)getAllFacts;
-(NSMutableArray *)getAllCommentsForFact:(NSInteger)fact_id;
-(NSMutableArray *)getTenCommentsForFact:(NSInteger)fact_id offsetNumber:(NSInteger)offset;
-(BOOL)insertFact:(SingleFact *)fact;
-(BOOL)insertComment:(SingleComment *)com;
-(BOOL)updateComment:(SingleComment *)com;
-(BOOL)clearFactDataTable;
-(BOOL)clearCommentsTable;
-(BOOL)clearCommentsForFact:(NSInteger)fact_id;
-(BOOL)updateLike:(NSInteger)liked forFact:(NSInteger)fact_id withNewLikeCount:(NSInteger)likeCount;
-(BOOL)updateLikeSync:(NSInteger)sync forFact:(NSInteger)fact_id;
-(BOOL)updateFact:(SingleFact *)fact;
-(BOOL)newCommentCount:(NSInteger)count forFact:(NSInteger)fact_id;
-(int)getLikeStatusForFact:(NSInteger)fact_id;
-(BOOL)DoesFactExistsInDb:(NSInteger)fact_id;

@end
