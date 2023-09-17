//
//  SignupViewController.m
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "SignupViewController.h"
#import "ActivateAppViewController.h"
#import "AppHelper.h"
#import "AgreementViewController.h"
#import "FactlDataAccess.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface SignupViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation SignupViewController

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

    _btnSignup.layer.borderWidth = 2.0f;
    _btnSignup.layer.cornerRadius = 4.0f;
    [[_btnSignup layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    [customButton setImage:[UIImage imageNamed:@"NavArrow-Back"] forState:UIControlStateNormal];
    [customButton setTitle:@"Back" forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(cancelSignup:)forControlEvents:UIControlEventTouchUpInside];
    customButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -20, 0, 0);
    customButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -19, 0, 0);
    [customButton sizeToFit];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"SIGN UP";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.txtFirstName addTarget:self action:@selector(checkFirstNameField:) forControlEvents:UIControlEventEditingChanged];
    
    [self.txtLastName addTarget:self action:@selector(checkLastNameField:) forControlEvents:UIControlEventEditingChanged];

    self.txtMobilePhone.backgroundColor = [UIColor whiteColor];
    self.txtMobilePhone.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtMobilePhone.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtMobilePhone.leftView = paddingView1;
    self.txtMobilePhone.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtFirstName.leftView = paddingView2;
    self.txtFirstName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtLastName.leftView = paddingView3;
    self.txtLastName.leftViewMode = UITextFieldViewModeAlways;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    _txtMobilePhone.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad{
    [_txtMobilePhone resignFirstResponder];
    _txtMobilePhone.text = @"";
}

-(void)doneWithNumberPad{
    [_txtMobilePhone resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.txtFirstName becomeFirstResponder];
    
    [[FactlAnalytics sharedFactlAnalytics] logScreenView:NSStringFromClass(self.class)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkFirstNameField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    NSString *firstName = textField.text;
    
    if(firstName.length > 0)
    {
        textField.text = [NSString stringWithFormat:@"%@%@",[[firstName substringToIndex:1] uppercaseString],[firstName substringFromIndex:1] ];
    }
}

- (void)checkLastNameField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    NSString *lastName = textField.text;
    
    if(lastName.length > 0)
    {
        textField.text = [NSString stringWithFormat:@"%@%@",[[lastName substringToIndex:1] uppercaseString],[lastName substringFromIndex:1] ];
    }
}

- (void)cancelSignup:(id)sender
{
    [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Cancel"];

    [self dismissViewControllerAnimated:YES completion:nil];
};

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1 || textField.tag == 2)
    {
        [self validateTextField:textField];
    }
    else if(textField.tag == 3)
    {
        [self validatePhoneField:textField];
        [_txtMobilePhone resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [_txtLastName becomeFirstResponder];
    }
    else if(textField.tag == 2)
    {
        [_txtMobilePhone becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 3)
    {
        NSUInteger length = [self getLength:textField.text];
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSUInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

-(NSUInteger)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
   return [mobileNumber length];
}

-(BOOL)validateTextField:(UITextField*)textField
{
    NSString *textData = textField.text;
    NSString *trimmedString = [textData stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString isEqualToString:@""])
    {
        textField.layer.cornerRadius = 0.0f;
        textField.layer.masksToBounds = YES;
        textField.layer.borderColor = [[UIColor redColor] CGColor];
        textField.layer.borderWidth = 1.0f;
        return NO;
    }
    else
    {
        textField.layer.borderColor = [[UIColor clearColor] CGColor];
        return YES;
    }
}

-(BOOL)validatePhoneField:(UITextField*)textField
{
    NSString *phoneRegex = @"^(\\([0-9]{3})\\) [0-9]{3}-[0-9]{4}$";
    NSPredicate *phone = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    BOOL isValid =[phone evaluateWithObject:textField.text];
    
    if (!isValid)
    {
        textField.layer.cornerRadius = 0.0f;
        textField.layer.masksToBounds = YES;
        textField.layer.borderColor = [[UIColor redColor] CGColor];
        textField.layer.borderWidth = 1.0f;
        return NO;
    }
    else
    {
        textField.layer.borderColor = [[UIColor clearColor] CGColor];
        return YES;
    }
}

- (IBAction)signUp:(id)sender
{
    if(!self.HUD)
    {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        self.HUD.delegate = self;
    }

    [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Signup New User"];

    [self signupNewUser];
}

- (IBAction)privacyPolicy:(id)sender
{
    [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Privacy Policy"];

    NSString* agreementFile = [[NSBundle mainBundle] pathForResource:@"Factl_Privacy_Policy" ofType:@"pdf"];

    AgreementViewController *agreementViewController = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil title:@"Privacy Policy" agreementFile:agreementFile];
    
    UINavigationController *agreementNavigationController = [[UINavigationController alloc] initWithRootViewController:agreementViewController];
    agreementNavigationController.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:agreementNavigationController animated:NO completion:nil];
}

- (IBAction)termsAndConditions:(id)sender
{
    [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Terms & Conditions"];

    NSString* agreementFile = [[NSBundle mainBundle] pathForResource:@"Factl_Terms_Conditions" ofType:@"pdf"];
    
    AgreementViewController *agreementViewController = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil title:@"Terms & Conditions" agreementFile:agreementFile];
    
    UINavigationController *agreementNavigationController = [[UINavigationController alloc] initWithRootViewController:agreementViewController];
    agreementNavigationController.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:agreementNavigationController animated:NO completion:nil];
}

-(void)signupNewUser
{
    BOOL validFirstName = [self validateTextField:self.txtFirstName];
    BOOL validLastName = [self validateTextField:self.txtLastName];
    BOOL validMobilePhone = [self validateTextField:self.txtMobilePhone] && [self validatePhoneField:self.txtMobilePhone];
    
    if(!validFirstName)
    {
        [self.txtFirstName becomeFirstResponder];
        return;
    }
    
    if(!validLastName)
    {
        [self.txtLastName becomeFirstResponder];
        return;
    }
    
    if(!validMobilePhone)
    {
        [self.txtMobilePhone becomeFirstResponder];
        return;
    }
    
    NSString *firstName = self.txtFirstName.text;
    NSString *lastName = self.txtLastName.text;
    NSString *mobilePhone = self.txtMobilePhone.text;
    
    FactlDataAccess *dataAccess = [[FactlDataAccess alloc] init];
    [dataAccess storeName:firstName lastName:lastName];
    
    NSString *baseUrl = [AppHelper getNewUserSignupUrl];
    
    [self.navigationController.view addSubview:self.HUD];
    [self.HUD showAnimated:YES];
    
    NSString *userId = [AppHelper getOwnerId];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseUrl
       parameters:@{@"UserId": userId, @"FirstName": firstName, @"LastName": lastName, @"PhoneNumber": mobilePhone}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [self.HUD hideAnimated:YES];
              
              NSString *ownerId = [responseObject objectForKey:@"OwnerId"];
              [AppHelper saveOwnerId:ownerId];
              
              NSString *userAlreadyExists = [responseObject objectForKey:@"IsNewUser"];
              
              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
              [defaults setValue:@"1" forKey:@"SignupComplete"];
              
              if ([userAlreadyExists boolValue])
              {
                  [defaults setValue:@"1" forKey:@"SetupComplete"];
              }
              [defaults synchronize];
              
              ActivateAppViewController *activateAppController = [[ActivateAppViewController alloc] initWithNibName:@"ActivateAppViewController" bundle:nil];
              
              UINavigationController *activateAppNavigationController = [[UINavigationController alloc] initWithRootViewController:activateAppController];
              [activateAppNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
              activateAppNavigationController.navigationBar.shadowImage = [UIImage new];
              activateAppNavigationController.navigationBar.translucent = YES;
              
              [self presentViewController:activateAppNavigationController animated:NO completion:nil];
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
          {
              [self.HUD hideAnimated:YES];
              NSLog(@"Error: %@", error);
          }];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
