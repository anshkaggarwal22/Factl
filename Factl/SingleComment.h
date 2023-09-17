//
//  SingleComment.h
//  Factl
//
//  Created by Kevin on 10/4/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleComment : NSObject

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, assign) NSInteger fact_id;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *author_id;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) long createdDate;
@property (nonatomic, assign) long modifiedDate;
@property (nonatomic, assign) NSInteger synced;

@end
