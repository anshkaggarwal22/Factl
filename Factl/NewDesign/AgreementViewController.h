//
//  AgreementViewController.h
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementViewController : UIViewController<UIWebViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title agreementFile:(NSString*)agreementFile;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
