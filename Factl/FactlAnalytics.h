//
//  FactlAnalytics.h
//  Factl
//
//  Created by anshaggarwal on 7/29/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface FactlAnalytics : NSObject

+ (id)sharedFactlAnalytics;

- (void)logScreen:(UIViewController*)viewController;
- (void)logScreenView:(NSString *)screenName;

- (void)logButtonPress:(NSString *)screenName button:(UIButton*)button;
- (void)logButtonPress:(NSString *)screenName buttonTitle:(NSString*)buttonTitle;

@end
