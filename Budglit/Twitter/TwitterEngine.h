//
//  TwitterEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"
#import "TwitterRequestObject.h"
#import "TwitterFeed.h"

@class Tweet;

typedef void (^OAuthTokenRequestResponse)(BOOL tokenGranted);
typedef void (^OAuthAccessTokenRequestResponse)(BOOL accessTokenGranted);
typedef void (^OAuthSignatureCreationResponse)(NSDictionary* signatureInfo);
typedef void (^OAuthTwitterResponse)(NSString* httpResponse);
typedef void (^TwitterResponseResult)(BOOL response, id responseObject);

@interface TwitterEngine : Engine

@property (strong, nonatomic) NSMutableArray* twitterRequestHistory;

-(id)initWithHostName:(NSString*)hostName andConsumerKey:(NSString*)key andConsumerSecret:(NSString*)secret;

-(void)extractTokenVerifierFromURL:(NSString*)URL;

-(NSDictionary*)getTokenVerifier;

-(BOOL)accessTokenExists;

-(TwitterFeed*)filterTwitterFeed:(TwitterFeed*)feed ByUserMention:(NSString*)username;

-(TwitterFeed*)filterTwitterFeed:(TwitterFeed*)feed ByHashtags:(NSString*)hashtag;

-(TwitterFeed*)filterTwitterFeed:(TwitterFeed*)feed Mentions:(NSString*)mention;

-(TwitterRequestObject*) constructAuthorizationParam:(TwitterRequestObject*)requestObject;

-(TwitterRequestObject*) constructAuthenticateRequest;

-(TwitterRequestObject*) constructTokenRequest:(NSDictionary*) additionalParams;

-(TwitterRequestObject*) constructAccessTokenRequest;

-(TwitterRequestObject*) constructSearchRequestWithParams:(NSDictionary*)params;

-(TwitterRequestObject*) constructRateLimitRequest:(NSArray*)queryFilter;

-(void)requestToken:(TwitterRequestObject*)request WithCompletionHandler:(OAuthTokenRequestResponse)completionBlock;

-(void)signInAuthenticateWithRequest:(TwitterRequestObject*)twitterRequest CompletionHandler:(OAuthTwitterResponse)completionBlock;

-(void)accessTokenRequest:(TwitterRequestObject*)twitterRequest CompletionHandler:(OAuthAccessTokenRequestResponse)completionBlock;

-(void)sendGeneralRequest:(TwitterRequestObject*)twitterRequest CompletionHandler:(TwitterResponseResult)completionBlock;

@end
