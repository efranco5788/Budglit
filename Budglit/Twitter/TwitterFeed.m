//
//  TwitterFeed.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/4/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "TwitterFeed.h"
#import "Tweet.h"
#import <TwitterKit/TWTRTweet.h>

#define TWITTER_SEARCH_RETURN_ENTITIES_KEY @"entities"
#define TWITTER_SEARCH_RETURN_HASHTAGS_KEY @"hashtags"
#define TWITTER_SEARCH_RETURN_HASHTAG_TEXT_KEY @"text"

@implementation TwitterFeed

-(instancetype)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)addListObject:(NSData*)object
{
    NSDictionary* extractedTweets = (NSDictionary*) object;
    
    NSArray* tweetsExtracted = extractedTweets[@"statuses"];
    
    NSArray* tweetArray = [Tweet tweetsWithJSONArray:tweetsExtracted];

    self.list = tweetArray;
    
    [self extractHashtagsForTweets:self.list];
}

-(void)addTweetToFeed:(Tweet *)tweet
{
    NSMutableArray* tmpFeedList = [self.list mutableCopy];
    
    [tmpFeedList addObject:tweet];
    
    self.list = tmpFeedList.copy;
}

-(void)extractHashtagsForTweets:(NSArray*)tweetArray
{
    if (!tweetArray) {
        return;
    }
    
    for (int count = 0; count < self.list.count; count++) {
        
        Tweet* tweet = tweetArray[count];
        
        NSMutableArray* mutableTags = tweet.hashtags.mutableCopy;
        
        NSArray* tags = [tweet valueForKey:TWITTER_SEARCH_RETURN_HASHTAGS_KEY];
        
        for (id tag in tags) {
            [mutableTags addObject:[tag valueForKey:TWITTER_SEARCH_RETURN_HASHTAG_TEXT_KEY]];
        }
        
    }
}


@end
