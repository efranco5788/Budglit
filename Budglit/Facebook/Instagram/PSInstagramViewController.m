//
//  PSInstagramViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "PSInstagramViewController.h"
#import "AppDelegate.h"
#import "InstagramManager.h"
#import "InstagramTableViewController.h"


#define RESTORATION_STRING @"instagramDetailViewController"

@interface PSInstagramViewController ()<InstagramManagerDelegate>

@end

@implementation PSInstagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = RESTORATION_STRING;
    [self.webView setDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.instagramManager setDelegate:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Start the activity loader in the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self toggleWebView:YES];
            [self.pageActivityIndicator startAnimating];
        });
        
        
        if (![appDelegate.instagramManager.engine accessTokenExists]) {
            NSString* apiURL = [appDelegate.instagramManager getAuthorizationURL_String];
            NSURL* url = [NSURL URLWithString:apiURL];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            NSLog(@"String is %@", request.URL);
            [self.webView loadRequest:request];
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
    NSURL* requestURL = [request URL];
    
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
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        NSString* url = [requestURL absoluteString];
        
        [appDelegate.instagramManager.engine retrieveAccessTokenFromString:url WithCompletionHandler:^(BOOL tokenGranted) {
            
            if (tokenGranted) {
                [appDelegate.instagramManager pullUserInfo];
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
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGRect frameSize = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, screenSize.size.width, self.view.bounds.size.height);
    
    [self.webView setFrame:frameSize];
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
        
        NSLog(@"Creating Table");
        
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        
        CGRect frameSize = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, screenSize.size.width, self.instagramTableView.view.frame.size.height);
        
        [self.instagramTableView.view setFrame:frameSize];
        
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
