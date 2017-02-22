//
//  Tweet.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/6/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "TwitterKit/TwitterKit.h"

@class Deal;
@class TWTRTweet;

@interface Tweet : TWTRTweet

@property (nonatomic, strong) Deal* deal;

@property (nonatomic, strong) NSDictionary* entities;

@property (nonatomic, strong) NSArray* hashtags;

+(NSArray *)tweetsWithJSONArray:(NSArray *)array;

-(void) addHashtags:(NSArray*)tags;


@end
