//
//  InstagramTableViewCell.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/11/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "InstagramObject.h"

@protocol InstaTableViewCellDelegate <NSObject>
@optional
-(void) webViewLoadedForObject:(InstagramObject*)obj;
@end

@interface InstagramTableViewCell : UITableViewCell<UIWebViewDelegate>

@property (strong, nonatomic) id <InstaTableViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

-(void)configure;

-(void)beginLoadingReuqest:(InstagramObject*)obj;

-(void)beginReuqest:(NSURL*)url;

-(void)displayInstagramView;



@end
