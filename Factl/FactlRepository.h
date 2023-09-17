//
//  FactlRepository.h
//  Factl
//
//  Created by anshaggarwal on 1/25/15.
//  Copyright (c) 2015 Factl. All rights reserved.
//

#ifndef Factl_FactlRepository_h
#define Factl_FactlRepository_h

@class SingleComment;
@class SingleFact;

@interface FactlRepository : NSObject

-(void)updateDeviceToken:(NSString *)existingToken oldToken:(NSString*)oldToken success:(void (^)(NSString *))success
                 failure:(void (^)(NSError *))failure;

-(void)likeFact:(NSInteger)factId
        success:(void (^)(NSString *))success
        failure:(void (^)(NSError *))failure;

-(void)unlikeFact:(NSInteger)factId
          success:(void (^)(NSString *))success
          failure:(void (^)(NSError *))failure;

-(void)addComment:(SingleComment *)comment
          success:(void (^)(NSString *))success
          failure:(void (^)(NSError *))failure;

-(void)getCommentsFromDatabase:(NSString*)userId
                    factId:(NSInteger)factId
                    success:(void (^)(NSString *))success
                    failure:(void (^)(NSError *))failure;

-(void)getNewFact:(void (^)(SingleFact *))success
          failure:(void (^)(NSError *))failure;

-(void)getDemoFact:(NSString*)userId
           success:(void (^)(SingleFact*))success
           failure:(void (^)(NSError *))failure;

-(void)getNewFactWithId:(NSInteger)factId
          success:(void (^)(NSString *))success
          failure:(void (^)(NSError *))failure;

-(void)getAllOldFacts:(NSString*)userId
              success:(void (^)(NSString *))success
              failure:(void (^)(NSError *))failure;

-(void)getUpdatedFactInfo:(NSString*)userId
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSError *))failure;

@end


#endif
