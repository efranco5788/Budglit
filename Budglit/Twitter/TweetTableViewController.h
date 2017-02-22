//
//  TweetTableViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/30/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterKit/TwitterKit.h"

@class TwitterFeed;
@class Tweet;

@protocol TwitterTableViewDelegate <NSObject>
@optional
-(void)tableview:(id)sender selectedTweetViewController:(TWTRTweetDetailViewController*)tweetVC;
@end

@interface TweetTableViewController : UITableViewController <TWTRTweetViewDelegate>

@property (nonatomic, strong) id <TwitterTableViewDelegate> tweetTableViewDelegate ;

-(void) reloadDataWithNewData;

@end
