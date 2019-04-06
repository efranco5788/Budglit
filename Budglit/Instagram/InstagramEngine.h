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

-(instancetype)initWithHostName:(NSString*)hostName andClientID:(NSString*)cID andClientSecret:(NSString*)secret NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL accessTokenExists;

//-(BOOL)accessTokenIsValid;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *constructAuthorizationURLString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *constructRecentMediaURLString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *constructUserURLString;

@property (NS_NONATOMIC_IOSONLY, getter=getAPI_Redirect_URI, readonly, copy) NSString *API_Redirect_URI;

-(void)sendInstagramRequest:(NSString*)strURL withCompletionHandler:(InstagramResponseResult) completionBlock;

-(void)retrieveAccessTokenFromString:(NSString*)urlStr WithCompletionHandler:(OAuthTokenRequestResponse)completionBlock;

@end
