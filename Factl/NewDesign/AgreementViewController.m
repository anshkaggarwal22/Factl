//
//  AgreementViewController.m
//  Factl
//
//  Created by anshaggarwal on 4/30/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()

@property (nonatomic, strong) NSString *agreementFile;

@end

@implementation AgreementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title agreementFile:(NSString*)agreementFile
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.navigationItem.title = title;
        self.agreementFile = agreementFile;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *targetURL = [NSURL fileURLWithPath:self.agreementFile];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(agreementReviewDone:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
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

- (void)agreementReviewDone:(id)sender
{
    [[FactlAnalytics sharedFactlAnalytics] logButtonPress:NSStringFromClass(self.class) buttonTitle:@"Agreement Review Done"];

    [self dismissViewControllerAnimated:YES completion:nil];
};

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([[[UIDevice currentDevice] systemVersion] integerValue] >= 8)
    {
        [self performSelector:@selector(clearBackground) withObject:nil afterDelay:0.1];
    }
}

- (void)clearBackground
{
    UIView *v = self.webView;
    while (v)
    {
        v.backgroundColor = [UIColor whiteColor];
        v = [v.subviews firstObject];
        
        if ([NSStringFromClass([v class]) isEqualToString:@"UIWebPDFView"]) {
            [v setBackgroundColor:[UIColor whiteColor]];
            
            // background set to white so fade view in and exit
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.webView.alpha = 1.0;
                             }
                             completion:nil];
            return;
        }
    }
}

@end
