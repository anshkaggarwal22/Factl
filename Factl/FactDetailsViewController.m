//
//  FactDetailsViewController.m
//  Factl
//
//  Created by Kevin on 10/3/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import "FactDetailsViewController.h"
#import "FactCell.h"
#import "CommentCell.h"
#import "FactlDataAccess.h"
#import "AppHelper.h"
#import "SingleComment.h"
#import "FactlRepository.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"

@interface FactDetailsViewController ()

@end

@implementation FactDetailsViewController
@synthesize factData;
@synthesize comments;
@synthesize hasPic;
@synthesize commentMode;
@synthesize moreComments;

- (void)viewDidLoad {
    [super viewDidLoad];

    comments = [self getComments];
    moreComments = YES;
    
    self.detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = @"Details";
    self.commentTextField.returnKeyType = UIReturnKeyDone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.commentView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0]];
    
    if(commentMode)
    {
        [self.commentTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)getComments
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    comments = [dataAccess getAllCommentsForFact:factData.fact_id];
    //comments = [dataAccess getTenCommentsForFact:factData.fact_id offsetNumber:0];
    return comments;
}

-(IBAction)postFact:(id)sender
{
    [self textFieldShouldReturn:self.commentTextField];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate*)[application delegate];
    
    if(appDelegate.isDemoMode)
    {
        [appDelegate launchInSignupMode:self.parentViewController];
        return YES;
    }

    
    if(textField.text == nil || [textField.text isEqual: @""])
    {
        return YES;
    }
    if(textField == _commentTextField)
    {
        [self submitNewComment:textField.text];
        textField.text = @"";
    }
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
    
    FactlRepository *repository = [[FactlRepository alloc] init];
    
    [repository addComment:com
                   success:^(NSString *success) {
                       NSLog(@"Successfully posted the comment");
                   } failure:^(NSError *failure) {
                       NSLog(@"failed to post the comment");
                       com.synced = 0;
                       [dataAccess updateComment:com];
                   }];

    [comments insertObject:com atIndex:0];
    [self.detailTableView reloadData];
}

-(void)addMoreComments:(UIButton *)sender
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    NSMutableArray *newComments = [dataAccess getTenCommentsForFact:factData.fact_id offsetNumber:[comments count]];
    if([newComments count] < 10)
    {
        moreComments = NO;
    }
    else
    {
        [comments addObjectsFromArray:newComments];
    }
    UIButton *newBtn = sender;
    if([comments count] == 0)
    {
        [newBtn setTitle:@"No comments yet!" forState:UIControlStateNormal];
    }
    else if(moreComments)
    {
        [newBtn setTitle:@"See more comments" forState:UIControlStateNormal];
    }
    else
    {
        [newBtn setTitle:@"No more comments" forState:UIControlStateNormal];
    }
    [self.detailTableView reloadData];
}

-(NSString *)convertTime: (long)time
{
    long currTime = [[NSDate date]timeIntervalSince1970];
    long timeDiff = (currTime - time)/60;
    if(timeDiff / 60 == 0 )
    {
        if(timeDiff%60 == 1)
            return [NSString stringWithFormat: @"%lu min", timeDiff%60];
        else
            return [NSString stringWithFormat: @"%lu mins", timeDiff%60];
    }
    else if((timeDiff / 60) / 24 == 0)
    {
        if((timeDiff/60)%24 == 1)
            return [NSString stringWithFormat: @"%lu hour", (timeDiff/60)%24];
        else
            return [NSString stringWithFormat: @"%lu hours", (timeDiff/60)%24];
    }
    else if(timeDiff > 0)
    {
        if((timeDiff/60/24)%30 == 1)
            return [NSString stringWithFormat: @"%lu day", (timeDiff/60/24)%30];
        else
        {
            long months = timeDiff/60/24/30;
            return [NSString stringWithFormat: @"%lu days", ((timeDiff/60/24)%30) + (months*30)];
        }
    }
    else
    {
        return @"A long time ago";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //comment count +1 for the "see more comments" +1 for the fact cell
    return [self.comments count] + 1;// + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        if(hasPic)
        {
            static NSString *factCellId = @"FactCell";
            
            FactCell *cell = (FactCell *)[tableView dequeueReusableCellWithIdentifier:factCellId];
            if(cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:factCellId owner:self options:nil];
                cell = [nib objectAtIndex: 0];
            }
                    
            cell.titleLabel.text = factData.title;
            cell.sourceLabel.text = [NSString stringWithFormat:@"by %@", factData.source];
            cell.ageLabel.text = [self convertTime:factData.createdDate];
            cell.factData = factData;
            [cell.factLabel setText:factData.fact withTruncation:NO];

            [cell.factImage sd_setImageWithURL:[NSURL URLWithString:factData.picFilePath]
                              placeholderImage:nil];

            NSString *commentsButtonText = [NSString stringWithFormat:@"%li comments", (long)factData.comments];
            NSString *likesButtonText = [NSString stringWithFormat:@"%li likes", (long)factData.likes];
            [cell.commentsBtn setTitle:commentsButtonText forState:UIControlStateNormal];
            [cell.likesBtn setTitle:likesButtonText forState:UIControlStateNormal];
            
            if(factData.is_favorite > 0)
            {
                //UIImage * filled_like = [UIImage imageNamed:@"like-filled-small"];
                //[cell.addLikeBtn setImage:filled_like forState:UIControlStateSelected];
                [cell.addLikeBtn setSelected: YES];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.factLabel.numberOfLines = 0;
            return cell;
        }
        else
        {
            static NSString *factCellNoPicId = @"FactCellNoPic";
            
            FactCellNoPic *cellNoPic = (FactCellNoPic *)[tableView dequeueReusableCellWithIdentifier:factCellNoPicId];
            if(cellNoPic == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:factCellNoPicId owner:self options:nil];
                cellNoPic = [nib objectAtIndex: 0];
            }
            
            cellNoPic.titleLabel.text = factData.title;
            cellNoPic.sourceLabel.text = [NSString stringWithFormat:@"by %@", factData.source];
            cellNoPic.ageLabel.text = [self convertTime:factData.createdDate];
            cellNoPic.factData = factData;
            [cellNoPic.factLabel setText:factData.fact withTruncation:NO];

            NSString *commentsButtonText = [NSString stringWithFormat:@"%li comments", (long)factData.comments];
            NSString *likesButtonText = [NSString stringWithFormat:@"%li likes", (long)factData.likes];
            [cellNoPic.commentsBtn setTitle:commentsButtonText forState:UIControlStateNormal];
            [cellNoPic.likesBtn setTitle:likesButtonText forState:UIControlStateNormal];
            
            if(factData.is_favorite > 0)
            {
                //UIImage * filled_like = [UIImage imageNamed:@"like-filled-small"];
                //[cellNoPic.addLikeBtn setImage:filled_like forState:UIControlStateSelected];
                [cellNoPic.addLikeBtn setSelected: YES];
            }
            
            cellNoPic.selectionStyle = UITableViewCellSelectionStyleNone;
            cellNoPic.factLabel.numberOfLines = 0;
            return cellNoPic;
        }
    }
    else //if(indexPath.row < [self.comments count] + 1)
    {
        SingleComment *curr = [self.comments objectAtIndex:indexPath.row - 1];
        
        static NSString *commentCellId = @"CommentCell";
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:commentCellId];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
            cell = [nib objectAtIndex: 0];
        }
        
        cell.authorLabel.text = [NSString stringWithFormat:@"by %@", curr.author];
        cell.ageLabel.text = [self convertTime: curr.createdDate];
        cell.commentLabel.text = curr.comment;
        cell.commentData = curr;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentLabel.numberOfLines = 0;
        return cell;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
@end
