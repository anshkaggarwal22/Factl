//
//  SignupViewController.h
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface SignupViewController : UIViewController<UITextFieldDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtMobilePhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)signUp:(id)sender;
- (IBAction)privacyPolicy:(id)sender;
- (IBAction)termsAndConditions:(id)sender;

@end
