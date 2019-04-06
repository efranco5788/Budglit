//
//  InstagramViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "InstagramViewController.h"
#import "AppDelegate.h"
#import "InstagramManager.h"
#import "InstagramTableViewController.h"


#define RESTORATION_STRING @"instagramDetailViewController"

@interface InstagramViewController ()<InstagramManagerDelegate>

@end

@implementation InstagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = RESTORATION_STRING;
    (self.webView).delegate = self;
    [self.webView setOpaque:NO];
    
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    (instagramManager).delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Start the activity loader in the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self toggleWebView:YES];
            [self.pageActivityIndicator startAnimating];
            
        });
        
        
        if (![instagramManager.engine accessTokenExists]) {
            
            NSString* apiURL = [instagramManager getAuthorizationURL_String];
            NSURL* url = [NSURL URLWithString:apiURL];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            NSLog(@"String is %@", request.URL);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:request];
            });
        }
        
    });
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark -
#pragma mark - Instagram Manager Delegate
-(void)instagramHTMLResponseSuccess:(NSString *)HTMLResponse
{
    [self.webView loadHTMLString:HTMLResponse baseURL:nil];
}

#pragma mark -
#pragma mark - Web View Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    NSURL* requestURL = request.URL;
    
    NSString* host = requestURL.host;
    
    NSLog(@"request host URL %@", requestURL.host);
    
    NSLog(@"Logs ------------------ %@", request);
    
    //NSLog(@"request URL %@", requestURL);
    
    if([host isEqualToString:@"restart"])
    {
        return NO;
    }
    else if ([host isEqualToString:@"www.budglit.com"])
    {
        NSString* url = requestURL.absoluteString;
        
        [instagramManager.engine retrieveAccessTokenFromString:url WithCompletionHandler:^(BOOL tokenGranted) {
            
            if (tokenGranted) {
                [instagramManager pullUserInfo];
            }
            
        }];
        
        return YES;
    }
    else if ([host isEqualToString:@"www.instagram.com"]) {
        [self toggleWebView:NO];
        return YES;
    }
    else return YES;
    
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{    
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

-(void)instagramUserInfoRetrieved
{
    [self toggleWebView:NO];
    
    [self toggleInstagramTableView];
}

-(void)frameWebView
{
    CGRect screenSize = self.view.superview.bounds;
    
    CGRect frameSize = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
    
    (self.webView).frame = frameSize;
}

-(void)toggleWebView:(BOOL)isHidden
{
    if (self.webView.isHidden || isHidden == NO) {
        [self.webView setHidden:NO];
        [self.pageActivityIndicator stopAnimating];
    }
    else if(isHidden == YES){
        [self.webView setHidden:YES];
    }
}

-(void)toggleInstagramTableView
{
    if (self.instagramTableView== nil) {
        
        self.instagramTableView = [[InstagramTableViewController alloc] initWithNibName:@"InstagramTableViewController" bundle:nil];
        
        CGRect frameSize= CGRectMake(0, 0, self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
        
        (self.instagramTableView.view).frame = frameSize;
        
        [self.view addSubview:self.instagramTableView.view];
    }
}


#pragma mark -
#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
