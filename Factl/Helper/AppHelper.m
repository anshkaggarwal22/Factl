//
//  AppHelper.m
//  Factl
//
//  Created by anshaggarwal on 5/4/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "AppHelper.h"
#import "UICKeyChainStore.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@implementation AppHelper

+(id)getPlistData:(NSString *)key
{
    NSString *path = [[NSBundle mainBundle] bundlePath];

    NSString *fileName = [NSString stringWithFormat:@"%@.%@", @"Info", @"plist"];

    NSString *finalPath = [path stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: finalPath];
    
    return [data objectForKey:key];
}

+(NSString *)getBaseUrl
{
    NSString *env = [AppHelper getPlistData:@"env"];
    
    NSDictionary *dictUrl = [AppHelper getPlistData:@"ApiUrl"];
    
    return [dictUrl objectForKey:env];
}

+(NSString *)getNewUserSignupUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Account/RegisterPhoneNumber", baseUrl];
}

+(NSString *)getNewUserWithoutPhoneNumberSignupUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Account/RegisterWithoutPhoneNumber", baseUrl];
}

+(NSString *)getActivationUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/Token", baseUrl];
}

+(NSString *)postNewCommentUrlWithFactId:(NSInteger)factId
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/%ld/Comment", baseUrl, (long)factId];
}

+(NSString *)getCommentsFromDatabaseUrlWithFactId:(NSInteger)factId
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/%ld/Comment", baseUrl, (long)factId];
}

+(NSString *)updateDeviceTokenUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/User/DeviceTokens", baseUrl];
}

+(NSString *)getAllOldFactsUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Fact", baseUrl];
}

+(NSString *)getFactWithIdUrl:(NSInteger)factId
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Fact/%ld", baseUrl, (long)factId];
}

+(NSString *)getNewFactUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/NewFact", baseUrl];
}

+(NSString *)getDemoFactUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/DemoFact", baseUrl];
}

+(NSString *)postLikeUrlWithFactId:(NSInteger)factId
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/%ld/Like", baseUrl, (long)factId];
}

+(NSString *)postUnlikeUrlWithFactId:(NSInteger)factId
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/%ld/UnLike", baseUrl, (long)factId];
}

+(NSString *)getLikesUrl
{
    NSString *baseUrl = [AppHelper getBaseUrl];
    
    return [NSString stringWithFormat:@"%@/api/Facts/Id/Like", baseUrl];
}

+(NSString*)getOwnerId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:@"OwnerId"];
}

+(void)saveOwnerId:(NSString*)ownerId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:ownerId forKey:@"OwnerId"];
    [defaults synchronize];
}

+(NSString*)getToken
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate*)[application delegate];

    if(appDelegate.isDemoMode)
        return @"";
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.factl"];
    return keychain[@"access_token"];
}

+(void)saveToken:(NSString*)accessToken
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate*)[application delegate];
    
    if(appDelegate.isDemoMode)
    {
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.factl"];
        keychain[@"access_token"] = @"";
    }
    else
    {
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.factl"];
        keychain[@"access_token"] = accessToken;
    }
}

@end

