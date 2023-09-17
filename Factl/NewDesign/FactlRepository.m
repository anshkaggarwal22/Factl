//
//  FactlRepository.m
//  Factl
//
//  Created by anshaggarwal on 1/25/15.
//  Copyright (c) 2015 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FactlRepository.h"
#import "AppHelper.h"
#import "FactlDataAccess.h"
#import "UserDeviceToken.h"
#import "SingleComment.h"

@implementation FactlRepository
{
    
}

-(void)updateDeviceToken:(NSString *)existingToken oldToken:(NSString*)oldToken success:(void (^)(NSString *))success
                 failure:(void (^)(NSError *))failure
{
    NSString *deviceTokenUrl = [AppHelper updateDeviceTokenUrl];
    
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *deviceTokenDictionary = [[NSMutableDictionary alloc] init];
    [deviceTokenDictionary setValue:existingToken forKey:@"DeviceToken"];
    [deviceTokenDictionary setValue:oldToken forKey:@"OldDeviceToken"];
    [deviceTokenDictionary setValue:@"apns" forKey:@"Platform"];
    
    [manager PUT:deviceTokenUrl parameters:deviceTokenDictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *registeredDeviceToken = [responseObject objectForKey:@"DeviceToken"];
         
         success(registeredDeviceToken);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failure");
         failure(error);
     }];
}

-(void)likeFact:(NSInteger)factId
        success:(void (^)(NSString *))success
        failure:(void (^)(NSError *))failure
{
    NSString *baseUrl = [AppHelper postLikeUrlWithFactId: factId];
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [manager POST:baseUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Successfully liked the fact");
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
}

-(void)unlikeFact:(NSInteger)factId
        success:(void (^)(NSString *))success
        failure:(void (^)(NSError *))failure
{
    NSString *baseUrl = [AppHelper postUnlikeUrlWithFactId:factId];
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [manager POST:baseUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Successfully unliked the fact");
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
}

-(void)addComment:(SingleComment *)comment
          success:(void (^)(NSString *))success
          failure:(void (^)(NSError *))failure
{
    NSString *baseUrl = [AppHelper postNewCommentUrlWithFactId:comment.fact_id];
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    NSLog(@"%@", baseUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [manager POST:baseUrl
       parameters:@{@"Comment":comment.comment}
          success:^(AFHTTPRequestOperation *operation, id responseObject)
          {
              NSLog(@"Successfully uploaded the comment");
              success(nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         failure(error);
     }];
}

-(void)getCommentsFromDatabase:(NSString*)userId
                    factId:(NSInteger)factId
                    success:(void (^)(NSString *))success
                    failure:(void (^)(NSError *))failure
{
    NSString *getCommentsUrl = [AppHelper getCommentsFromDatabaseUrlWithFactId:factId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getCommentsUrl
      parameters: @{@"userId": userId}
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
         
         SingleComment *temp = [[SingleComment alloc] init];
         NSArray *allComments = [[NSArray alloc] initWithArray:responseObject];
         for(id comment in allComments)
         {
             temp.fact_id = [[comment objectForKey:@"FactId"] integerValue];
             temp.comment = [comment objectForKey:@"Comment"];
             temp.author = [comment objectForKey:@"CommentByUser"];
             temp.author_id = [comment objectForKey:@"CommentByUserId"];
             temp.createdDate = [[comment objectForKey:@"CreatedDate"] longValue];
             temp.modifiedDate = [[comment objectForKey:@"ModifiedDate"] longValue];
             temp.synced = 1;
             
             [dataAccess insertComment:temp];
         }
         success(nil);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure(error);
     }
     ];
}

-(void)getNewFactWithId:(NSInteger)factId
          success:(void (^)(NSString *))success
          failure:(void (^)(NSError *))failure
{
    NSString *getFactURL = [AppHelper getFactWithIdUrl:factId];
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"%@", authorizationHeaderValue);
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [manager GET:getFactURL
      parameters: nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
             
             SingleFact *temp = [[SingleFact alloc] init];
             temp.fact_id = [[responseObject objectForKey:@"Id"] integerValue];
             temp.title = [responseObject objectForKey:@"Title"];
             temp.source = [responseObject objectForKey:@"Author"];
             temp.picFilePath = [responseObject objectForKey:@"ImageFileName"];
             temp.fact = [responseObject objectForKey:@"FactDescription"];
             temp.likes = [[responseObject objectForKey:@"likesCount"] integerValue];
             temp.comments = [[responseObject objectForKey:@"commentsCount"] integerValue];
             temp.createdDate = [[responseObject objectForKey:@"CreatedDate"] integerValue];
             temp.modifiedDate = [[responseObject objectForKey:@"ModifiedDate"] integerValue];
             temp.receivedDate = [[responseObject objectForKey:@"ReceivedDate"] integerValue];
             temp.is_favorite = [[responseObject objectForKey:@"IsFavorite"] integerValue];;
             NSLog(@"%i", [dataAccess insertFact:temp]);
             
             success(nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             failure(error);
         }
     ];
}

-(void)getNewFact:(void (^)(SingleFact*))success
          failure:(void (^)(NSError *))failure
{
    NSString *getFactURL = [AppHelper getNewFactUrl];
    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", [AppHelper getToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [manager GET:getFactURL
      parameters: nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
         
         SingleFact *temp = [[SingleFact alloc] init];
         temp.fact_id = [[responseObject objectForKey:@"Id"] integerValue];
         temp.title = [responseObject objectForKey:@"Title"];
         temp.source = [responseObject objectForKey:@"Author"];
         temp.picFilePath = [responseObject objectForKey:@"ImageFileName"];
         temp.fact = [responseObject objectForKey:@"FactDescription"];
         temp.likes = [[responseObject objectForKey:@"likesCount"] integerValue];
         temp.comments = [[responseObject objectForKey:@"commentsCount"] integerValue];
         temp.createdDate = [[responseObject objectForKey:@"CreatedDate"] integerValue];
         temp.modifiedDate = [[responseObject objectForKey:@"ModifiedDate"] integerValue];
         temp.receivedDate = [[responseObject objectForKey:@"ReceivedDate"] integerValue];
         temp.is_favorite = [[responseObject objectForKey:@"IsFavorite"] integerValue];
         NSLog(@"%i", [dataAccess insertFact:temp]);
         
         success(temp);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error);
         failure(error);
     }
     ];
}

-(void)getAllOldFacts:(NSString*)userId
        success:(void (^)(NSString *))success
        failure:(void (^)(NSError *))failure
{
    NSString *getFactsURL = [AppHelper getAllOldFactsUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getFactsURL
      parameters: @{@"userId": userId}
         success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
             FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
             
             NSArray *allFacts = [[NSArray alloc] initWithArray:responseObject];
             for(id fact in allFacts)
             {
                 SingleFact *temp = [[SingleFact alloc] init];
                 temp.fact_id = [[fact objectForKey:@"Id"] integerValue];
                 temp.title = [fact objectForKey:@"Title"];
                 temp.source = [fact objectForKey:@"Author"];
                 temp.picFilePath = [fact objectForKey:@"ImageFileName"];
                 temp.fact = [fact objectForKey:@"FactDescription"];
                 temp.likes = [[fact objectForKey:@"likesCount"] integerValue];
                 temp.comments = [[fact objectForKey:@"commentsCount"] integerValue];
                 temp.createdDate = [[fact objectForKey:@"CreatedDate"] integerValue];
                 temp.modifiedDate = [[fact objectForKey:@"ModifiedDate"] integerValue];
                 temp.receivedDate = [[fact objectForKey:@"ReceivedDate"] integerValue];
                 temp.is_favorite = [[fact objectForKey:@"IsFavorite"] integerValue];
                 
                 [dataAccess insertFact:temp];
             }
            success(nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error with loading all facts: %@", error);
         failure(error);
     }];
}

-(void)getUpdatedFactInfo:(NSString*)userId
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSError *))failure
{
    NSString *getFactsURL = [AppHelper getAllOldFactsUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getFactsURL
    parameters: @{@"userId": userId}
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
         FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
         
         NSArray *allFacts = [[NSArray alloc] initWithArray:responseObject];
         for(id fact in allFacts)
         {
             NSInteger factId = [[fact objectForKey:@"Id"] integerValue];
             BOOL factExists = [dataAccess DoesFactExistsInDb:factId];
             
             if(factExists)
             {
                 SingleFact *temp = [[SingleFact alloc] init];
                 temp.fact_id = [[fact objectForKey:@"Id"] integerValue];
                 temp.likes = [[fact objectForKey:@"likesCount"] integerValue];
                 temp.comments = [[fact objectForKey:@"commentsCount"] integerValue];
                 temp.picFilePath = [fact objectForKey:@"ImageFileName"];
                 temp.is_favorite = [[fact objectForKey:@"IsFavorite"] integerValue];
                 NSLog(@"%@", temp.picFilePath);
                 
                 NSLog(@"%i", [dataAccess updateFact:temp]);
             }
             else
             {
                 SingleFact *temp = [[SingleFact alloc] init];
                 temp.fact_id = [[fact objectForKey:@"Id"] integerValue];
                 temp.title = [fact objectForKey:@"Title"];
                 temp.source = [fact objectForKey:@"Author"];
                 temp.picFilePath = [fact objectForKey:@"ImageFileName"];
                 temp.fact = [fact objectForKey:@"FactDescription"];
                 temp.likes = [[fact objectForKey:@"likesCount"] integerValue];
                 temp.comments = [[fact objectForKey:@"commentsCount"] integerValue];
                 temp.createdDate = [[fact objectForKey:@"CreatedDate"] integerValue];
                 temp.modifiedDate = [[fact objectForKey:@"ModifiedDate"] integerValue];
                 temp.receivedDate = [[fact objectForKey:@"ReceivedDate"] integerValue];
                 temp.is_favorite = [[fact objectForKey:@"IsFavorite"] integerValue];
                 
                 [dataAccess insertFact:temp];
             }

         }
         success(nil);
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error with updating facts: %@", error);
         failure(error);
     }];
}

-(void)getDemoFact:(NSString*)userId
        success:(void (^)(SingleFact*))success
        failure:(void (^)(NSError *))failure
{
    NSString *getFactURL = [AppHelper getDemoFactUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager GET:getFactURL
    parameters: @{@"userId": userId}
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];

        SingleFact *temp = [[SingleFact alloc] init];
        temp.fact_id = [[responseObject objectForKey:@"Id"] integerValue];
        temp.title = [responseObject objectForKey:@"Title"];
        temp.source = [responseObject objectForKey:@"Author"];
        temp.picFilePath = [responseObject objectForKey:@"ImageFileName"];
        temp.fact = [responseObject objectForKey:@"FactDescription"];
        temp.likes = [[responseObject objectForKey:@"likesCount"] integerValue];
        temp.comments = [[responseObject objectForKey:@"commentsCount"] integerValue];
        temp.createdDate = [[responseObject objectForKey:@"CreatedDate"] integerValue];
        temp.modifiedDate = [[responseObject objectForKey:@"ModifiedDate"] integerValue];
        temp.receivedDate = [[responseObject objectForKey:@"ReceivedDate"] integerValue];
        temp.is_favorite = [[responseObject objectForKey:@"IsFavorite"] integerValue];
        NSLog(@"%i", [dataAccess insertFact:temp]);

        success(temp);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@", error);
        failure(error);
    }
    ];
}

@end
