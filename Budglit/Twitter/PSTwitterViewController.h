//
//  PSTwitterViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/29/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTwitterWebView.h"
//#import "TwitterKit/TwitterKit.h"
#import "SocialMediaViewController.h"
#import <WebKit/WebKit.h>

@class TweetTableViewController;
@class TwitterRequestObject;
@class TweetDetailViewController;
@class Deal;

@protocol TwitterViewDelegate <NSObject>
@optional
-(void)webViewWithContentView:(CGSize)contentArea;
@end

@interface PSTwitterViewController : SocialMediaViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIToolbar *twitterFilterToolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *userMention_Filter;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *hashtag_Filter;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mentions_Filter;
@property (strong, nonatomic) id <TwitterViewDelegate> twitterDelegate;
@property (strong, nonatomic) TweetTableViewController* tweetsView;
@property (strong, nonatomic) Deal* currentDeal;

- (IBAction)filterPressed:(UIBarButtonItem *)sender;

- (IBAction)signInButtonPressed:(id)sender;

-(void)toggleWebView;

-(void)toggleSignInButton;

-(void)toggleTweetView;

-(void)toggleTwitterFilterToolbar;

@end
