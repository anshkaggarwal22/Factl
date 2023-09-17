//
//  CommentCell.m
//  Factl
//
//  Created by Kevin on 10/4/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import "CommentCell.h"
#import "FactlRepository.h"
#import "FactlDataAccess.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
    [self updateComment:textField.text];
    return YES;
}

- (void) updateComment:(NSString *)comment
{
    self.commentData.comment = comment;
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    [dataAccess updateComment:self.commentData];
}

@end
