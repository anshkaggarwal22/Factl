//
//  HomeViewController.m
//  Factl
//
//  Created by Kevin on 9/19/16.
//  Copyright © 2016 Factl. All rights reserved.
//

#import "HomeViewController.h"
#import "FactCell.h"
#import "FactCellNoPic.h"
#import "FactlDataAccess.h"
#import "AppHelper.h"
#import "FactDetailsViewController.h"
#import "FactlRepository.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize facts;
@synthesize getFactButton;
@synthesize homeButton;
@synthesize favoritesButton;
@synthesize loaded;
@synthesize show_favorites;
@synthesize refreshControl;
@synthesize HUD;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate*)[application delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(presentFactlViewOnPushNotification)
                                        name:@"HAS_PUSH_NOTIFICATION"
                                        object:nil];
    
    [self.toolbar setBarTintColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0]];
    
    [self formatBarButtonItems];
    
    if(show_favorites)
    {
        self.navigationItem.title = @"Favorites";
        
        [self.homeButton setEnabled:NO];
        [self.homeButton setImage:nil];

        [self.getFactButton setEnabled:NO];
        [self.getFactButton setImage:nil];
    }
    else
    {
        self.navigationItem.title = @"Factl";
        
        [self.homeButton setEnabled:YES];
        [self.homeButton setImage:[[UIImage imageNamed:@"home-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        [self.getFactButton setEnabled:YES];
        [self.getFactButton setImage:[[UIImage imageNamed:@"lightbulb-white-80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    refreshControl.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1];
    refreshControl.tintColor = [UIColor colorWithRed:25.0/255.0 green:127.0/255.0 blue:0.0/255.0 alpha:1];

    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    HUD.delegate = self;

    [self loadFacts];
    if(!appDelegate.isNewUser && !show_favorites)
    {
        [self refreshTable];
    }
    
    if(show_favorites)
    {
        [self.tableView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(show_favorites && self.facts.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Favorites"
                                                        message:@"Doesn't look like you have any favorited facts yet. Try pressing the thumbs up in the bottom left corner of the facts to save them here!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }

    if(!loaded)
    {
        //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height) animated:YES];
    }
    loaded = YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)presentFactlViewOnPushNotification
{
    [self refreshTable];
}

-(void)getComments:(FactlRepository *)repository
{
    NSString *userId = [AppHelper getOwnerId];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
    {
        for(SingleFact * fact in facts)
        {
            [repository getCommentsFromDatabase:userId
                                        factId:fact.fact_id
                                        success:^(NSString *success) {}
                                        failure:^(NSError *error) {}];
        }
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSLog(@"done getting comments from server");
            if([refreshControl isRefreshing])
            {
                [refreshControl endRefreshing];
            }
        });
    });
}

-(void) formatBarButtonItems
{
    UIImage *favorite = [[UIImage imageNamed:@"like-white-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *home = [[UIImage imageNamed:@"home-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *getFact = [[UIImage imageNamed:@"lightbulb-white-80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [homeButton setImage:home];
    [getFactButton setImage:getFact];
    [favoritesButton setImage:favorite];
}

-(void)refreshTable
{
    NSString *userId = [AppHelper getOwnerId];
    if([NSString isNilOrEmpty:userId])
        return;

    [refreshControl beginRefreshing];

    FactlRepository *repository = [[FactlRepository alloc] init];
    
    [repository getUpdatedFactInfo:userId success:^(NSString *success) {
        
        if([refreshControl isRefreshing])
        {
            [refreshControl endRefreshing];
        }
        
        [self getComments:repository];
        
        [self loadFacts];
        
        if(!show_favorites && self.facts.count == 0)
        {
            [self getNewFact:nil];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        if([refreshControl isRefreshing])
        {
            [refreshControl endRefreshing];
        }
        NSLog(@"%@", error);
    }];
}

-(IBAction)showFavorites:(id)sender
{
    if(!show_favorites)
    {
        HomeViewController *favoriteViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        favoriteViewController.show_favorites = YES;
        favoriteViewController.loaded = YES;
        [self.navigationController pushViewController:favoriteViewController animated:YES];
    }
}

- (void)loadFacts
{
    FactlDataAccess *dataAccess = [FactlDataAccess sharedFactlDbAccess];
    self.facts = [dataAccess getAllFacts];
    if(show_favorites == YES)
    {
        NSMutableArray *notFavorites = [NSMutableArray array];
        SingleFact *f;
        for (f in self.facts) {
            if (f.is_favorite <= 0)
                [notFavorites addObject:f];
        }
        
        [self.facts removeObjectsInArray:notFavorites];
    }
}

-(IBAction)getNewFact:(id)sender
{
    if(show_favorites)
        return;
    
    FactlRepository *repository = [[FactlRepository alloc] init];
    
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate*)[application delegate];
    
    NSString *userId = [AppHelper getOwnerId];

    if(!appDelegate.isDemoMode)
    {
        [repository getNewFact:^(SingleFact *newFact)
        {
            [self loadFacts];

            if(newFact != nil)
            {
                [repository getCommentsFromDatabase:userId
                                    factId:newFact.fact_id
                                    success:^(NSString *success) {
                                         [self.tableView beginUpdates];
                                         NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
                                         [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:firstRow] withRowAnimation:UITableViewRowAnimationTop];
                                         [self.tableView endUpdates];
                                     }
                                     failure:^(NSError *error) {
                                     }];
            }

        }
        failure:^(NSError *error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facts Left!"
                                                     message:@"Looks like you already have all the facts. Check back tomorrow for a new one!"
                                                    delegate:self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
            [alert show];
        }];
    }
    else
    {
        [repository getDemoFact:userId success:^(SingleFact *newFact) {
        
            [self loadFacts];

            if(newFact != nil)
            {
                [repository getCommentsFromDatabase:userId
                                            factId:newFact.fact_id
                                            success:^(NSString *success) {
                                                [self.tableView beginUpdates];
                                                NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
                                                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:firstRow] withRowAnimation:UITableViewRowAnimationTop];
                                                [self.tableView endUpdates];
                                                
                                            }
                                            failure:^(NSError *error) {
                                            }];
            }
        }
        failure:^(NSError *error) {
            
        }];
    }
}

-(void)launchDetailViewWithFact:(SingleFact * )fact withComment:(bool)comment
{
    NSString *userId = [AppHelper getOwnerId];

    FactlRepository *repository = [[FactlRepository alloc] init];
    
    [repository getCommentsFromDatabase:userId
                                factId:fact.fact_id
                                success:^(NSString *success) {
                                    [self internalLaunchDetailViewWithFact:fact withComment:comment];
                                }
                                failure:^(NSError *error) {
                                    [self internalLaunchDetailViewWithFact:fact withComment:comment];
                                    
                                }];
}

-(void)internalLaunchDetailViewWithFact:(SingleFact * )fact withComment:(bool)comment
{
    FactDetailsViewController *factDetails = [[FactDetailsViewController alloc] initWithNibName:@"FactDetailsViewController" bundle:nil];
    
    FactlDataAccess *dataAccess = [[FactlDataAccess alloc] init];
    fact.is_favorite = [dataAccess getLikeStatusForFact:fact.fact_id];
    factDetails.factData = fact;
    
    if(factDetails.factData.picFilePath != nil)
    {
        factDetails.hasPic = YES;
    }
    else
    {
        factDetails.hasPic = NO;
    }
    factDetails.commentMode = comment;
    [self.navigationController pushViewController:factDetails animated:YES];
}

-(IBAction)homeButton:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
    return [self.facts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *factCellId = @"FactCell";
    static NSString *factCellNoPicId = @"FactCellNoPic";
    
    FactCell *cell = (FactCell *)[tableView dequeueReusableCellWithIdentifier:factCellId];
    FactCellNoPic *cellNoPic = (FactCellNoPic *)[tableView dequeueReusableCellWithIdentifier:factCellNoPicId];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FactCell" owner:self options:nil];
        cell = [nib objectAtIndex: 0];
    }
    if(cellNoPic == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FactCellNoPic" owner:self options:nil];
        cellNoPic = [nib objectAtIndex: 0];
    }
    
    SingleFact *curr = [self.facts objectAtIndex:indexPath.row];
    
    FactlDataAccess *dataAccess = [[FactlDataAccess alloc] init];
    curr.is_favorite = [dataAccess getLikeStatusForFact:curr.fact_id];
    
    NSString *commentsButtonText = [NSString stringWithFormat:@"%li comments", (long)curr.comments];
    NSString *likesButtonText = [NSString stringWithFormat:@"%li likes", (long)curr.likes];

    if(curr.picFilePath != nil)
    {
        [cell.factImage sd_setImageWithURL:[NSURL URLWithString:curr.picFilePath]
                          placeholderImage:nil];
    }
    
    //also good to implement here would be a check to see if the app can connect to the internet: if it can't, it should display no-pic facts
    if([curr.picFilePath length] == 0)
    {
        curr.picFilePath = nil;
        cellNoPic.factData = curr;
        cellNoPic.parent = self;
        cellNoPic.titleLabel.text = curr.title;
        cellNoPic.sourceLabel.text = [NSString stringWithFormat:@"by %@", curr.source];
        cellNoPic.ageLabel.text = [self convertTime:curr.createdDate];
        [cellNoPic.factLabel setText:curr.fact withTruncation:YES];

        if(curr.is_favorite > 0)
        {
            UIImage * filled_like = [UIImage imageNamed:@"like-filled-small"];
            [cellNoPic.addLikeBtn setImage:filled_like forState:UIControlStateSelected];
            [cellNoPic.addLikeBtn setSelected: YES];
        }
        
        [cellNoPic.commentsBtn setTitle:commentsButtonText forState:UIControlStateNormal];
        [cellNoPic.likesBtn setTitle:likesButtonText forState:UIControlStateNormal];
        return cellNoPic;
    }
    else
    {
        cell.factData = curr;
        cell.parent = self;
        cell.titleLabel.text = curr.title;
        cell.sourceLabel.text = [NSString stringWithFormat:@"by %@", curr.source];
        cell.ageLabel.text = [self convertTime:curr.createdDate];
        
        [cell.factLabel setText:curr.fact withTruncation:YES];

        if(curr.is_favorite > 0)
        {
            UIImage * filled_like = [UIImage imageNamed:@"like-filled-small"];
            [cell.addLikeBtn setImage:filled_like forState:UIControlStateSelected];
            [cell.addLikeBtn setSelected: YES];
        }
        
        [cell.commentsBtn setTitle:commentsButtonText forState:UIControlStateNormal];
        [cell.likesBtn setTitle:likesButtonText forState:UIControlStateNormal];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self launchDetailViewWithFact:[self.facts objectAtIndex:indexPath.row] withComment:NO];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperview];
    HUD = nil;
}


@end
