//
//  AppDelegate.m
//  Factl
//
//  Created by anshaggarwal on 4/20/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "SignupViewController.h"
#import "SetupViewController.h"
#import "ActivateAppViewController.h"
#import "HomeViewController.h"
#import "FactlRepository.h"
#import "SingleComment.h"
#import "SingleFact.h"
#import "TPKeyboardAvoidingScrollView.h"

#import "FactlDataAccess.h"
#import "AppHelper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"

@interface AppDelegate ()

@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;

@end

static NSString *serverURL = @"https://tumbleweed-rail-3807.twil.io/register-binding";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];
    [TPKeyboardAvoidingScrollView class]; //prevents class from being optimized out

    
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                            NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0]
                                                            }];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0]];

    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"NavArrow-Back"]];

    // Set NavigationBar Button Color & Font
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:18.0]} forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:18.0]} forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica Neue" size:16.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    self.databaseName = @"Factl.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
    
    [self createAndCheckDatabase];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL signupComplete = [[defaults objectForKey:@"SignupComplete"] boolValue];
    BOOL activationComplete = [[defaults objectForKey:@"ActivationComplete"] boolValue];
    
    if (!signupComplete || !activationComplete)
    {
        [self launchInDemoMode:application];
    }
    else
    {
        if (launchOptions)
        {
            //launchOptions is not nil
            NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
            
            if (apsInfo)
            {
                if(!self.window)
                {
                    [self syncDatabases];
                    [self launchInRegularMode:application];
                }
                
                //apsInfo is not nil
                [self performSelector:@selector(postNotificationToPresentPushMessagesVC)
                           withObject:nil
                           afterDelay:1];
            }
        }
        else
        {
            [self syncDatabases];
            [self launchInRegularMode:application];
        }
    }

    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //this method can be done using the notification as well
    [self postNotificationToPresentPushMessagesVC];
}

-(void)postNotificationToPresentPushMessagesVC {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HAS_PUSH_NOTIFICATION" object:nil];
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self registerDevice:deviceToken identity:[AppHelper getOwnerId]];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

-(void) registerDevice:(NSData *) deviceToken identity:(NSString *) identity
{
    // Create a POST request to the /register endpoint with device variables to register for Twilio Notifications
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSDictionary *params = @{@"identity": identity,
                             @"endpoint": [NSString stringWithFormat:@"%@,%@", identity, deviceTokenString],
                             @"BindingType": @"apn",
                             @"Address": deviceTokenString};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    request.HTTPBody = jsonData;
    
    NSString *requestBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Request: %@", requestBody);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", responseString);
        
        if (error == nil) {
            id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"JSON: %@", response);
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
    [task resume];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Below code will make sure that app continues to run for certian amount of time
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)launchInGettingStartedMode:(UIApplication*)application
{
    if (!self.window)
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    SetupViewController *setupViewController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
    
    UINavigationController *setupNavigationController = [[UINavigationController alloc] initWithRootViewController:setupViewController];
    setupNavigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = setupNavigationController;
    [self.window makeKeyAndVisible];
}

-(void)launchInSignupMode:(UIViewController*)parent
{
    SignupViewController *signupViewController = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    
    UINavigationController *signupNavigationController = [[UINavigationController alloc] initWithRootViewController:signupViewController];
    
    [signupNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    signupNavigationController.navigationBar.shadowImage = [UIImage new];
    signupNavigationController.navigationBar.translucent = YES;
    
    [parent presentViewController:signupNavigationController animated:NO completion:nil];
}

-(void)launchInDemoMode:(UIApplication*)application
{
    if (!self.window)
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    self.isDemoMode = YES;
    
    NSString *userId = [AppHelper getOwnerId];
    if([NSString isNilOrEmpty:userId])
        userId = @" ";
    
    NSString *baseUrl = [AppHelper getNewUserWithoutPhoneNumberSignupUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseUrl
       parameters:@{@"UserId": userId}
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *previousOwnerId = [AppHelper getOwnerId];
         
         NSString *ownerId = [responseObject objectForKey:@"OwnerId"];
         [AppHelper saveOwnerId:ownerId];
         
         if([NSString isNilOrEmpty:previousOwnerId])
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"HAS_PUSH_NOTIFICATION" object:nil];
         }
         
         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
         {
             UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
             [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 if (granted) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [application registerForRemoteNotifications];
                     });
                 }
             }];
         }
         else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
         {
             [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                            settingsForTypes:(UIUserNotificationTypeSound |
                                                                              UIUserNotificationTypeAlert |
                                                                              UIUserNotificationTypeBadge)
                                                            categories:nil]];
             
             [application registerForRemoteNotifications];
         }
         else
         {
             [application registerForRemoteNotifications];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
    
    HomeViewController *homeViewController = [[HomeViewController alloc]
                                              initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *factlNavigationViewController = [[UINavigationController alloc]
                                                             initWithRootViewController:homeViewController];
    
    self.window.rootViewController = factlNavigationViewController;
    [self.window makeKeyAndVisible];
}

-(void)launchInRegularMode:(UIApplication*)application
{
    if (!self.window)
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    self.isDemoMode = NO;

    HomeViewController *homeViewController = [[HomeViewController alloc]
                                            initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *factlNavigationViewController = [[UINavigationController alloc]
                                                             initWithRootViewController:homeViewController];
    if(_isNewUser)
    {
        FactlRepository *repository = [[FactlRepository alloc] init];
        NSString *userId = [AppHelper getOwnerId];

        [repository getAllOldFacts:userId
         success:^(NSString *success)
         {
             NSLog(@"Successfully got all the facts");
             [homeViewController refreshTable];
         }
         failure:^(NSError *error)
         {
             NSLog(@"Error with getting all the facts: %@", error);
         }];
        
    }
    self.window.rootViewController = factlNavigationViewController;
    [self.window makeKeyAndVisible];
}

- (void)resetDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:self.databasePath];
    
    if(success)
    {
        [fileManager removeItemAtPath:self.databasePath error:nil];
    }
    
    [self createAndCheckDatabase];
}

- (void)createAndCheckDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:self.databasePath];

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

    if(success)
    {
        NSString* appVersion = [userDefaults stringForKey:@"SnagletVersion"];
        
        if ([NSString isNilOrEmpty:appVersion])
        {
            [userDefaults setObject:@"1.1" forKey:@"SnagletVersion"];
            [userDefaults synchronize];
        }
        return;
    }
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];

    [userDefaults setObject:@"1.1" forKey:@"SnagletVersion"];
    [userDefaults synchronize];
}

//goes through all facts and all comments to check for ones that are not synced. This is O(n^2), which is obviously not ideal.
//if the app remains small scall, then this isn't that big of an issue. However, if it grows, it could lead to performance issues.
//Proposed solution:
//implement another local database table. This table will keep track of what is not synced, instead of keeping track of that data
//in the comments and fact data tables. This reduces the problem to O(n), and has the additional benefit of only running if there is
//unsynced data. 
-(void)syncDatabases
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    FactlRepository *repository = [[FactlRepository alloc] init];
    NSMutableArray *facts = [dataAccess getAllFacts];
    NSMutableArray *comments;
    
    for(SingleFact *fact in facts)//@@@@@update sync status for these
    {
        if(fact.like_synced == 0)
        {
            if(fact.is_favorite > 0)
            {
                [repository likeFact:(NSInteger)fact.fact_id
                 success:^(NSString *success)
                 {
                     NSLog(@"synced fact like");
                     [dataAccess updateLikeSync:1 forFact:fact.fact_id];
                     fact.like_synced = 1;
                 }
                 failure:^(NSError *error)
                 {
                     NSLog(@"Error with syncing like for fact: %@", error);
                 }];
            }
        }
        comments = [dataAccess getAllCommentsForFact:fact.fact_id];
        for(SingleComment *com in comments)
        {
            if(com.synced == 0)
            {
                [repository addComment:com
                               success:^(NSString *success) {
                                   NSLog(@"Successfully synced the comment");
                                   com.synced = 1;
                                   [dataAccess updateComment:com];

                               } failure:^(NSError *failure) {
                                   NSLog(@"failed to sync the comment");
                               }];
            }
        }
    }
}

@end
