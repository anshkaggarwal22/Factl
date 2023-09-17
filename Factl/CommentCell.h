//
//  CommentCell.h
//  Factl
//
//  Created by Kevin on 10/4/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleComment.h"
#import "ResponsiveLabel.h"

@interface CommentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet ResponsiveLabel *authorLabel;
@property (nonatomic, weak) IBOutlet ResponsiveLabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;

@property (nonatomic, strong) SingleComment *commentData;

@end
