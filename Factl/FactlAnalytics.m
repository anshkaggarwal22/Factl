//
//  FactlAnalytics.m
//  Factl
//
//  Created by anshaggarwal on 7/29/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//


#import "FactlAnalytics.h"
#import <Google/Analytics.h>
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface FactlAnalytics ()

- (id)init;

@end

@implementation FactlAnalytics

+ (id)sharedFactlAnalytics
{
    static FactlAnalytics *factlAnalytics = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factlAnalytics = [[self alloc] init];
    });
    return factlAnalytics;
}

- (id)init
{
    if (self = [super init])
    {
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-83126831-1"];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        [tracker set:kGAIAppVersion value:version];
        [tracker set:kGAISampleRate value:@"50.0"];
    }
    return self;
}

- (void)logScreen:(UIViewController*)viewController
{
    [self logScreenView:NSStringFromClass([viewController class])];
}

- (void)logScreenView:(NSString *)screenName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker send:[[[GAIDictionaryBuilder createScreenView] set:screenName forKey:kGAIScreenName] build]];

    [tracker set:kGAIScreenName value:nil];
}

- (void)logButtonPress:(NSString *)screenName button:(UIButton*)button
{
    [self logButtonPress:screenName buttonTitle:[button.titleLabel text]];
}

- (void)logButtonPress:(NSString *)screenName buttonTitle:(NSString*)buttonTitle
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:buttonTitle
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

@end
