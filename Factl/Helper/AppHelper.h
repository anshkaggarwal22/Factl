//
//  AppHelper.h
//  Factl
//
//  Created by anshaggarwal on 5/4/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppHelper : NSObject

+(id)getPlistData:(NSString *)key;

+(NSString*)getBaseUrl;

+(NSString *)getNewUserSignupUrl;

+(NSString *)getNewUserWithoutPhoneNumberSignupUrl;

+(NSString *)getActivationUrl;

+(NSString *)postNewCommentUrlWithFactId:(NSInteger)factId;

+(NSString *)getCommentsFromDatabaseUrlWithFactId:(NSInteger)factId;

+(NSString *)getAllOldFactsUrl;

+(NSString *)getNewFactUrl;

+(NSString *)getDemoFactUrl;

+(NSString *)getFactWithIdUrl:(NSInteger)factId;

+(NSString *)postLikeUrlWithFactId:(NSInteger)factId;

+(NSString *)postUnlikeUrlWithFactId:(NSInteger)factId;

+(NSString *)getLikesUrl;

+(NSString *)updateDeviceTokenUrl;

+(NSString*)getOwnerId;
+(void)saveOwnerId:(NSString*)ownerId;

+(NSString*)getToken;
+(void)saveToken:(NSString*)accessToken;

@end

