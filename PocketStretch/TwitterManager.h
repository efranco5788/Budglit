//
//  TwitterManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/29/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterKit/TwitterKit.h"

@class Deal;
@class TwitterFeed;
@class TwitterEngine;
@class TwitterRequestObject;

@protocol TwitterManagerDelegate <NSObject>
@optional
-(void)twitterGeneralRequestSucessful;
-(void)twitterGeneralRequestFailed;
-(void)twitterAccessTokenGranted;
-(void)twitterTokenGranted;
-(void)twitterHTMLResponseSuccess:(NSString*) HTMLResponse;
-(void)twitterFilteredTweetsReturned;
@end

@interface TwitterManager : NSObject

@property (nonatomic, strong) TwitterEngine* engine;
@property (nonatomic, strong) TwitterFeed* filteredTmpTwitterFeed;
@property (nonatomic, strong) id <TwitterManagerDelegate> delegate;

-(id) initWithEngineHostName:(NSString*)hostName andTwitterKeys:(NSDictionary*) keys;

-(NSUInteger)totalTweetsCurrentlyLoaded;

-(TWTRTweet*)tweetAtIndex:(NSUInteger)index;

-(BOOL) accessTokenExists;

-(BOOL) userSignedIn;

-(void)twitterExtractTokenVerifierFromURL:(NSString*)URL;

-(TwitterRequestObject*)constructTwitterSearchRequestForDeal:(Deal*)deal;

-(TwitterRequestObject*)constructTwitterTokenRequest;

-(TwitterRequestObject*)constructTwitterAccessTokenRequest;

-(TwitterRequestObject*)constructTwitterAuthenticateRequest;

-(TwitterRequestObject*) constructTwitterRateLimitRequest:(NSArray*)query;

-(void)twitterSignInAuthenticateRequest:(TwitterRequestObject*)request;

-(void)twitterTokenRequest:(TwitterRequestObject*)request;

-(void)twitterAccessTokenRequest:(TwitterRequestObject*) request;

-(void)twitterSendGeneralRequest:(TwitterRequestObject*)twitterRequest;

-(void)filterTwitterFeedBy:(NSInteger)filterType forEntity:(id)entity;

@end
