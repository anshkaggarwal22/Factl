//
//  SingleFact.h
//  Factl
//
//  Created by Kevin on 9/21/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleFact : NSObject

@property (nonatomic, assign) NSInteger fact_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *picFilePath;
@property (nonatomic, strong) NSString *fact;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) long createdDate;
@property (nonatomic, assign) long modifiedDate;
@property (nonatomic, assign) NSInteger is_favorite;
@property (nonatomic, assign) NSInteger like_synced;
@property (nonatomic, assign) long receivedDate;

@end
