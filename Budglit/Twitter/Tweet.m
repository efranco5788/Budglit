//
//  Tweet.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/6/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "Tweet.h"
#import "Deal.h"

@implementation Tweet
@synthesize hashtags;

+(NSArray *)tweetsWithJSONArray:(NSArray *)array
{
    //NSArray* tweetArray = [super tweetsWithJSONArray:array];
    NSArray* tweetArray;
    return tweetArray;
}

-(id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)addHashtags:(NSArray *)tags
{
    self.hashtags = tags.copy;
}

@end
