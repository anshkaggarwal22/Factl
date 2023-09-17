//
//  FactCellNoPic.h
//  Factl
//
//  Created by Kevin on 10/28/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "SingleFact.h"
#import "HomeViewController.h"
#import "ResponsiveLabel.h"

@interface FactCellNoPic : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *factView;
@property (nonatomic, weak) IBOutlet ResponsiveLabel *titleLabel;
@property (nonatomic, weak) IBOutlet ResponsiveLabel *sourceLabel;
@property (nonatomic, weak) IBOutlet ResponsiveLabel *ageLabel;
@property (nonatomic, weak) IBOutlet ResponsiveLabel *factLabel;
@property (nonatomic, weak) IBOutlet UIButton *likesBtn;
@property (nonatomic, weak) IBOutlet UIButton *commentsBtn;
@property (nonatomic, weak) IBOutlet UIButton *addLikeBtn;
@property (nonatomic, weak) IBOutlet UIButton *addCommentBtn;
@property (nonatomic, weak) IBOutlet UIButton *shareBtn;
@property (nonatomic, weak) IBOutlet UIView *inLineCommentView;
@property (nonatomic, weak) IBOutlet UITextField *inLineCommentTextField;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIView *shareView;

@property (nonatomic, strong) SingleFact *factData;
@property (nonatomic, strong) HomeViewController *parent;

- (IBAction)toggleLike:(id)sender;
- (IBAction)inlineComments:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)shareToTwitter:(id)sender;
- (IBAction)shareToFacebook:(id)sender;
- (IBAction)launchDetailView;
- (IBAction)launchDetailViewWithComment;

@end
