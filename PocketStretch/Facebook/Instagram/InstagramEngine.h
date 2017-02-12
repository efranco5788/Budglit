//
//  InstagramEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

typedef void (^OAuthTokenRequestResponse)(BOOL tokenGranted);
typedef void (^InstagramResponseResult)(NSData* response);

@interface InstagramEngine : Engine

-(id)initWithHostName:(NSString*)hostName andClientID:(NSString*)cID andClientSecret:(NSString*)secret;

-(BOOL)accessTokenExists;

//-(BOOL)accessTokenIsValid;

-(NSString*)constructAuthorizationURLString;

-(NSString*)constructRecentMediaURLString;

-(NSString*)constructUserURLString;

-(NSString*)getAPI_Redirect_URI;

-(void)sendInstagramRequest:(NSString*)strURL withCompletionHandler:(InstagramResponseResult) completionBlock;

-(void)retrieveAccessTokenFromString:(NSString*)urlStr WithCompletionHandler:(OAuthTokenRequestResponse)completionBlock;;

@end
