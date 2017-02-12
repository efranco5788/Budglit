//
//  PSTwitterViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/29/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSTwitterViewController.h"
#import "AppDelegate.h"
#import "Deal.h"
#import "TweetTableViewController.h"
#import "TwitterRequestObject.h"
#import "TweetDetailViewController.h"
#import "UIDevice-Extension/UIDevice-Hardware.h"

#define kDEFAULT_IMAGE_NAME @"empty_filter_app_icon_unselected.png"

@interface PSTwitterViewController ()<TwitterManagerDelegate, TwitterTableViewDelegate, UIWebViewDelegate>

@end

@implementation PSTwitterViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.webView setDelegate:self];
    
    [self.webView setHidden:YES];
    
    [self.twitterFilterToolBar setHidden:YES];
    
    [self.filterButton setImage:[UIImage imageNamed:kDEFAULT_IMAGE_NAME]];
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.twitterManager setDelegate:self];
    
    BOOL tokenStatus = [appDelegate.twitterManager accessTokenExists];
    
    if (tokenStatus) {
        
        BOOL signedIn = [appDelegate.twitterManager userSignedIn];
        
        [self toggleSignInButton];
        
        [self toggleWebView];
        
        if (signedIn){
            
            TwitterRequestObject* searchTweets = [appDelegate.twitterManager constructTwitterSearchRequestForDeal:self.currentDeal];
            
            [appDelegate.twitterManager twitterSendGeneralRequest:searchTweets];
        }
        else{
            
            TwitterRequestObject* authenticateRequest = [appDelegate.twitterManager constructTwitterAuthenticateRequest];
            
            [appDelegate.twitterManager twitterSignInAuthenticateRequest:authenticateRequest];
        }
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
}

-(void)viewWillLayoutSubviews
{
    CGRect newFrame = CGRectInset(self.view.frame, 1, 1);
    
    //self.signInButton.center = CGPointMake(self.view.frame.size.width / 2, self.signInButton.center.y);
    
    [self.signInButton setFrame:newFrame];
    
    [super viewDidLayoutSubviews];
}


- (IBAction)signInButtonPressed:(id)sender {
    
    [self toggleSignInButton];
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.twitterManager setDelegate:self];
    
    BOOL tokenStatus = [appDelegate.twitterManager accessTokenExists];
    
    if (tokenStatus) {
        
        BOOL signedIn = [appDelegate.twitterManager userSignedIn];
        
        if (signedIn){
            
            if (self.webView.isHidden) {
                [self toggleWebView];
            }
            
            TwitterRequestObject* searchTweets = [appDelegate.twitterManager constructTwitterSearchRequestForDeal:self.currentDeal];
            
            [appDelegate.twitterManager twitterSendGeneralRequest:searchTweets];
        }
        
    }
    else{
        
        TwitterRequestObject* tokenRequest = [appDelegate.twitterManager constructTwitterTokenRequest];
        
        [appDelegate.twitterManager twitterTokenRequest:tokenRequest];
    }
    
}

-(void)frameWebView
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGRect frameSize = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, screenSize.size.width, self.view.bounds.size.height);
    
    [self.webView setFrame:frameSize];
}

-(void)toggleWebView
{
    if (self.webView.isHidden) {
        [self frameWebView];
        [self.webView setHidden:NO];
    }
    else{
        [self.webView setHidden:YES];
    }
}


-(void)toggleSignInButton
{
    if (self.signInButton.isHidden) {
        [self.signInButton setHidden:NO];
    }
    else [self.signInButton setHidden:YES];
}

-(void)toggleTweetView
{
    if (self.tweetsView == nil) {
        
        self.tweetsView = [[TweetTableViewController alloc] initWithNibName:@"TweetTableViewController" bundle:nil];
        
        [self.tweetsView setTweetTableViewDelegate:self];
        
        [self.view addSubview:self.tweetsView.view];
    }
}

-(void)toggleTwitterFilterButton
{
    
    if ([self.filterButton.image isEqual:[UIImage imageNamed:@"empty_filter_app_icon_unselected.png"]]) {
        
        [self.filterButton setImage:[UIImage imageNamed:@"empty_filter_app_icon_selected.png"]];
        
    }
    else [self.filterButton setImage:[UIImage imageNamed:@"empty_filter_app_icon_unselected.png"]];
}

-(void)toggleTwitterFilterToolbar
{
    if (self.twitterFilterToolBar.isHidden) {
        [self.twitterFilterToolBar setHidden:NO];
        [self.view bringSubviewToFront:self.twitterFilterToolBar];
    }
    else [self.twitterFilterToolBar setHidden:YES];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* requestURL = [request URL];
    
    NSString* host = requestURL.host;
    
    NSLog(@"request host URL %@", requestURL);
    
    if([host isEqualToString:@"restart"])
    {
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        NSString* URL = [requestURL absoluteString];
        
        [appDelegate.twitterManager twitterExtractTokenVerifierFromURL:URL];
        
        TwitterRequestObject* accessTokenRequest = [appDelegate.twitterManager constructTwitterAccessTokenRequest];
        
        [appDelegate.twitterManager twitterAccessTokenRequest:accessTokenRequest];
        
        return NO;
        
    }
    else return YES;
    
}

#pragma mark -
#pragma mark - Twitter Table View Delegate
-(void)tableview:(id)sender selectedTweetViewController:(TWTRTweetDetailViewController *)tweetVC
{
    TweetDetailViewController* tv = (TweetDetailViewController*) tweetVC;
    
    [self.navigationController pushViewController:tv animated:YES
     ];
}


#pragma mark -
#pragma mark - Twitter Manager Delegate
-(void)twitterTokenGranted
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [self toggleWebView];
    
    TwitterRequestObject* authenticateRequest = [appDelegate.twitterManager constructTwitterAuthenticateRequest];
    
    [appDelegate.twitterManager twitterSignInAuthenticateRequest:authenticateRequest];
}

-(void)twitterAccessTokenGranted
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    TwitterRequestObject* searchTweets = [appDelegate.twitterManager constructTwitterSearchRequestForDeal:self.currentDeal];
    
    //NSLog(@"%@", searchTweets.requestSignatureBase);
    
    [appDelegate.twitterManager twitterSendGeneralRequest:searchTweets];
}

-(void)twitterGeneralRequestSucessful
{
    if (!self.webView.isHidden) {
        [self toggleWebView];
        [self toggleTweetView];
        [self toggleTwitterFilterToolbar];
    }
    
}

-(void)twitterFilteredTweetsReturned
{
    [self.tweetsView reloadDataWithNewData];
}

-(void)twitterHTMLResponseSuccess:(NSString *)HTMLResponse
{
    [self.webView loadHTMLString:HTMLResponse baseURL:nil];
}

#pragma mark -
#pragma mark - Web View Delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize scrollView = webView.scrollView.contentSize;
    
    [self.twitterDelegate webViewWithContentView:scrollView];
}

- (IBAction)filterPressed:(UIBarButtonItem *)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString* entity;

    switch (sender.tag) {
        case 0:{
            entity = self.currentDeal.venueTwtrUsername;
            [appDelegate.twitterManager filterTwitterFeedBy:0 forEntity:entity];
        }
            break;
        case 1:{
            NSArray* dealTags = self.currentDeal.tags.copy;
            if (dealTags.count == 1) {
                entity = [dealTags firstObject];
            }
            else if ([dealTags isEqual:[NSNull null]])
            {
                entity = nil;
            }
            
            [appDelegate.twitterManager filterTwitterFeedBy:1 forEntity:entity];
        }
            break;
        case 2:{
            entity = self.currentDeal.venueName;
            [appDelegate.twitterManager filterTwitterFeedBy:2 forEntity:entity];
        }
            break;
        case 3:{
            [appDelegate.twitterManager filterTwitterFeedBy:3 forEntity:nil];
            [self toggleTwitterFilterButton];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
