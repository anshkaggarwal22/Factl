//
//  AppDelegate.h
//  Factl
//
//  Created by anshaggarwal on 4/20/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NSString *databaseName;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic, assign) BOOL isNewUser;
@property (nonatomic, assign) BOOL isDemoMode;

@property (copy) void (^sessionCompletionHandler)();

-(void)launchInGettingStartedMode:(UIApplication*)application;

-(void)launchInRegularMode:(UIApplication*)application;
-(void)launchInDemoMode:(UIApplication*)application;
-(void)launchInSignupMode:(UIViewController*)parent;

-(void)resetDatabase;

@end
