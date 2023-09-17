//
//  ActivateAppViewController.h
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivateAppViewController : UIViewController<UITextFieldDelegate, MBProgressHUDDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@property (weak, nonatomic) IBOutlet UIButton *btnActivate;
@property (weak, nonatomic) IBOutlet UITextField *txtPinCode;

- (IBAction)activateApp:(id)sender;

@end
