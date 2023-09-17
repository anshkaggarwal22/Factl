//
//  SetupViewController.h
//  Factl
//
//  Created by anshaggarwal on 4/20/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SetupViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)getStarted:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnMobile;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end
