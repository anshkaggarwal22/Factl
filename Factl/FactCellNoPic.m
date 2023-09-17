//
//  FactCellNoPic.m
//  Factl
//
//  Created by Kevin on 10/28/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import "FactCellNoPic.h"
#import "FactlDataAccess.h"
#import "AppHelper.h"
#import "SingleComment.h"
#import "FactlRepository.h"
#import "ResponsiveLabel.h"

@implementation FactCellNoPic

@synthesize factData;
@synthesize parent;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.inLineCommentView.hidden = YES;
    self.shareView.hidden = YES;
    self.ageLabel.hidden = YES;
    self.inLineCommentTextField.returnKeyType = UIReturnKeyDone;

    [self.likesBtn setTitleColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0] forState:UIControlStateNormal &
     UIControlStateHighlighted &
     UIControlStateSelected];

    [self.commentsBtn setTitleColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0] forState:UIControlStateNormal &
     UIControlStateHighlighted &
     UIControlStateSelected];
    
    PatternTapResponder tap = ^(NSString *string)
    {
        self.factLabel.numberOfLines = 0;
        [UIView setAnimationsEnabled:NO];
        [parent.tableView beginUpdates];
        [parent.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
    };
    
    NSString *expansionToken = @" ...more";
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:expansionToken attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0],NSFontAttributeName:self.factLabel.font, RLTapResponderAttributeName:tap}];
    
    [self.factLabel setAttributedTruncationToken:attribString];
    
    self.shareBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(IBAction)launchDetailView
{
    [parent launchDetailViewWithFact:factData withComment:NO];
}

- (IBAction)launchDetailViewWithComment
{
    [parent launchDetailViewWithFact:factData withComment:YES];
}

- (IBAction)toggleLike:(id)sender
{/*
    if([sender isSelected])
    {
        UIImage * no_like = [UIImage imageNamed:@"like-small"];
        [sender setImage:no_like forState:UIControlStateNormal];
        [sender setSelected: NO];
        [self updateDatabaseLike:-1];
    }
    else
    {
        UIImage * like = [UIImage imageNamed:@"like-filled-small"];
        [sender setImage:like forState:UIControlStateSelected];
        [sender setSelected: YES];
        [self updateDatabaseLike:(NSInteger)1];
    }*/
    
    if(factData.is_favorite > 0)
    {
        factData.is_favorite = -1;
        //UIImage * no_like = [UIImage imageNamed:@"like-small"];
        //[sender setImage:no_like forState:UIControlStateNormal];
        [sender setSelected: NO];
        [self updateDatabaseLike:-1];
    }
    else
    {
        factData.is_favorite = 1;
        //UIImage * like = [UIImage imageNamed:@"like-filled-small"];
        //[sender setImage:like forState:UIControlStateNormal];
        [sender setSelected: YES];
        [self updateDatabaseLike:1];
    }
}

-(void)updateDatabaseLike:(NSInteger)liked
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    factData.likes += liked;
    [dataAccess updateLike:liked forFact:factData.fact_id withNewLikeCount:(factData.likes)];
    
    NSString *likesButtonText = [NSString stringWithFormat:@"%li likes", (long)(factData.likes)];
    [self.likesBtn setTitle:likesButtonText forState:UIControlStateNormal];
    
    FactlRepository *repository = [[FactlRepository alloc] init];
    if(liked == 1)
    {
        [repository likeFact:(NSInteger)self.factData.fact_id
                     success:^(NSString *success)
         {
             NSLog(@"Successfully liked fact");
         }
                     failure:^(NSError *error)
         {
             NSLog(@"Error with liking fact: %@", error);
         }];
    }
    else
    {
        [repository unlikeFact:(NSInteger)self.factData.fact_id
                     success:^(NSString *success)
         {
             NSLog(@"Successfully unliked fact");
         }
                     failure:^(NSError *error)
         {
             NSLog(@"Error with unliking fact: %@", error);
         }];
    }
}

- (IBAction)share:(id)sender
{
    if(self.shareView.hidden)
    {
        self.shareView.hidden = NO;
    }
    else
    {
        self.shareView.hidden = YES;
    }
}

-(IBAction)inlineComments:(id)sender
{
    //removing inline commenting for no 
    //self.inLineCommentView.hidden = NO;
    //[self.inLineCommentTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.inLineCommentView.hidden = YES;
    if(textField.text == nil || [textField.text isEqual: @""])
    {
        return YES;
    }
    [self submitNewComment:textField.text];
    textField.text = @"";
    return YES;
}

- (void)submitNewComment:(NSString *)comment
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    SingleComment *com = [[SingleComment alloc] init];
    com.comment = comment;
    com.author = [dataAccess getName];
    com.author_id = [AppHelper getOwnerId];
    com.fact_id = factData.fact_id;
    com.synced = 1;
    factData.comments++;
    
    [dataAccess insertComment:com];
    [dataAccess newCommentCount:(factData.comments) forFact:factData.fact_id];
    
    NSString *commentsButtonText = [NSString stringWithFormat:@"%li comments", (long)(factData.comments)];
    [self.commentsBtn setTitle:commentsButtonText forState:UIControlStateNormal];
    
    FactlRepository *repository = [[FactlRepository alloc] init];
    
    [repository addComment:com
                   success:^(NSString *success) {
                       NSLog(@"Successfully posted the comment");
                   } failure:^(NSError *failure) {
                       NSLog(@"failed to post the comment");
                       com.synced = 0;
                       [dataAccess updateComment:com];
                   }];
}

-(IBAction)shareToTwitter:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetController setInitialText:self.factData.fact];
        [parent presentViewController:tweetController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Account Found"
                                                        message:@"We couldn't find a Twitter account on this phone! If you already have the app installed, double check to make sure that you're logged in. Thanks!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)shareToFacebook:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookController setInitialText:self.factData.fact];
        [parent presentViewController:facebookController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account Found"
                                                        message:@"We couldn't find a Facebook account on this phone! If you already have the app installed, double check to make sure that you're logged in. Thanks!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
