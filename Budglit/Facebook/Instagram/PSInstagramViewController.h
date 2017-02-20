//
//  PSInstagramViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SocialMediaViewController.h"

@class InstagramManager;
@class InstagramTableViewController;

@interface PSInstagramViewController : SocialMediaViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pageActivityIndicator;

@property (strong, nonatomic) InstagramTableViewController* instagramTableView;


@end
