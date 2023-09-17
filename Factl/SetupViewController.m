//
//  SetupViewController.m
//  Factl
//
//  Created by anshaggarwal on 4/20/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "SetupViewController.h"
#import "SignupViewController.h"
#import "ActivateAppViewController.h"
#import "AppDelegate.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    [self.view setBackgroundColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0]];
    
    UIImage *lightbulb = [[UIImage imageNamed:@"light-bulb-3-256x256.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imageView setImage:lightbulb];
    [_imageView setTintColor:[UIColor whiteColor]];
    
    self.btnMobile.layer.borderWidth = 2.0f;
    self.btnMobile.layer.cornerRadius = 4.0f;
    [[self.btnMobile layer] setBorderColor:[UIColor whiteColor].CGColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[FactlAnalytics sharedFactlAnalytics] logScreenView:NSStringFromClass(self.class)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getStarted:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL signupComplete = [[defaults objectForKey:@"SignupComplete"] boolValue];
    BOOL activationComplete = [[defaults objectForKey:@"ActivationComplete"] boolValue];
    
    if ((!signupComplete || !activationComplete) && [sender tag] == 1)
    {
        UIApplication *application = [UIApplication sharedApplication];
        AppDelegate *appDelegate = (AppDelegate*)[application delegate];
        [appDelegate resetDatabase];

        [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Getting Started"];
        
        SignupViewController *signupViewController = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
        
        UINavigationController *signupNavigationController = [[UINavigationController alloc] initWithRootViewController:signupViewController];
        
        [signupNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        signupNavigationController.navigationBar.shadowImage = [UIImage new];
        signupNavigationController.navigationBar.translucent = YES;
        
        [self presentViewController:signupNavigationController animated:NO completion:nil];
    }
}

@end
