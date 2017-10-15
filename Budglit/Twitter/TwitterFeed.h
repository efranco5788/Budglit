//
//  TwitterFeed.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/4/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Fabric/Fabric.h>
#import "SocialMediaFeed.h"
#import <TwitterKit/TwitterKit.h>

@class Tweet;

@interface TwitterFeed : SocialMediaFeed

-(instancetype)init;

-(void)addTweetToFeed:(Tweet*)tweet;

-(void) extractHashtagsForTweets:(NSArray*)tweetArray;

@end
