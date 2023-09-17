//
//  FactDetailsViewController.h
//  Factl
//
//  Created by Kevin on 10/3/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleFact.h"
#import "FactCell.h"
#import "FactCellNoPic.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface FactDetailsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *commentTextField;
@property (nonatomic, weak) IBOutlet UIButton *postCommentBtn; 
@property (nonatomic, weak) IBOutlet UITableView *detailTableView;
@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (nonatomic, strong) SingleFact *factData;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) BOOL hasPic;
@property (nonatomic, assign) BOOL commentMode;
@property (nonatomic, assign) BOOL moreComments;

//- (IBAction)toggleLike:(id)sender;

@end
