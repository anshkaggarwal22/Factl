//
//  HomeViewController.h
//  Factl
//
//  Created by Kevin on 9/19/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleFact.h"

@interface HomeViewController : UIViewController<MBProgressHUDDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *getFactButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *homeButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *favoritesButton;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) BOOL show_favorites;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, strong) NSMutableArray *facts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(IBAction)showFavorites:(id)sender;
-(IBAction)getNewFact:(id)sender;
-(IBAction)homeButton:(id)sender; 
-(void)loadFacts;
-(void)refreshTable;
-(void)launchDetailViewWithFact:(SingleFact * )fact withComment:(bool)comment;
@end
