//
//  ActivateAppViewController.m
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "ActivateAppViewController.h"
#import "AppHelper.h"
#import "AppDelegate.h"
#import "SingleFact.h"
#import "FactlDataAccess.h"
#import "FactlRepository.h"

@interface ActivateAppViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ActivateAppViewController

@synthesize txtPinCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.00 green:0.69 blue:0.94 alpha:1.0]];

    _btnActivate.layer.borderWidth = 2.0f;
    _btnActivate.layer.cornerRadius = 4.0f;
    [[_btnActivate layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.HUD.delegate = self;

    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    //[customButton setImage:[UIImage imageNamed:@"NavArrow-Back"] forState:UIControlStateNormal];
    [customButton setTitle:@"Back" forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(cancelActivation:)forControlEvents:UIControlEventTouchUpInside];
    customButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -20, 0, 0);
    customButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -19, 0, 0);
    [customButton sizeToFit];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"VERIFY PIN";
    
    self.txtPinCode.backgroundColor = [UIColor whiteColor];
    self.txtPinCode.delegate = self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtPinCode.leftView = paddingView;
    self.txtPinCode.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.txtPinCode becomeFirstResponder];
    
    
    [[FactlAnalytics sharedFactlAnalytics] logScreenView:NSStringFromClass(self.class)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self validateTextField:textField];
    [textField resignFirstResponder];
}

-(BOOL)validateTextField:(UITextField*)textField
{
    NSString *textData = textField.text;
    NSString *trimmedString = [textData stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString isEqualToString:@""])
    {
        [self displayPinError];
        return NO;
    }
    else
    {
        textField.layer.borderColor = [[UIColor clearColor] CGColor];
        return YES;
    }
}

-(void)displayPinError
{
    txtPinCode.layer.cornerRadius = 0.0f;
    txtPinCode.layer.masksToBounds = YES;
    txtPinCode.layer.borderColor = [[UIColor redColor] CGColor];
    txtPinCode.layer.borderWidth = 1.0f;
    txtPinCode.text = @"";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                    message:@"Looks like that wasn't the PIN we sent you. Try entering it again!"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)activateApp:(id)sender
{
    if ([self validateTextField:self.txtPinCode])
    {
        [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Activate App"];

        NSString *ownerId = [AppHelper getOwnerId];
        NSString *pinCode = self.txtPinCode.text;
        
        [self.txtPinCode resignFirstResponder];
        
        NSString *activationUrl = [AppHelper getActivationUrl];
        
        [self.navigationController.view addSubview:self.HUD];
        [self.HUD showAnimated:TRUE];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:activationUrl
           parameters:@{@"grant_type":@"password", @"username": ownerId, @"password": pinCode}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  [self.HUD hideAnimated:YES];
                  
                  UIApplication *application = [UIApplication sharedApplication];
                  AppDelegate *appDelegate = (AppDelegate*)[application delegate];

                  appDelegate.isDemoMode = NO;
                  appDelegate.isNewUser = YES;

                  NSString *accessToken = [responseObject objectForKey:@"access_token"];
                  [AppHelper saveToken:accessToken];
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  [defaults setValue:@"1" forKey:@"ActivationComplete"];
                  [defaults synchronize];
                  
                  [appDelegate resetDatabase];
                  
                  [appDelegate launchInRegularMode:application];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  [self.HUD hideAnimated:YES];
                  [self displayPinError];

                  NSLog(@"Error: %@", error);
              }];
        
    }
}

- (void)cancelActivation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
};

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
