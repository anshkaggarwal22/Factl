//
//  UserDeviceToken.h
//  Factl
//
//  Created by anshaggarwal on 7/17/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDeviceToken : NSObject

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *oldDeviceToken;
@property (nonatomic, strong) NSString *platform;

@end
