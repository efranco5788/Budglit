//
//  OAuthObject.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/6/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthObject : NSObject

@property (nonatomic, strong) NSString* OAuthVersion;

//-(void)setOAuthVersion:(NSInteger)version;

-(NSString*) generate_NONCEToken;

-(NSString*) generate_Timestamp;

-(NSString*) getSignautreMethod;

-(NSString*) getOAUTHVersion;

-(NSString*) getAuthorizationHeaderKey;

-(NSString*) encodeParameters:(NSDictionary*) parameters;

-(NSString*) constructAuthorizationString:(NSDictionary*)authorizationHeader;

-(NSString*) createSignatureBaseWithMethod:(NSString*)httpMethod andBaseURL:(NSString*)baseURL andParameterString:(NSString*)paramString andQuery:(NSString*)query;

-(NSString*) createSigningKeyConsumerSecret:(NSString*)consumerSecret andTokenSecret:(NSString*)tokenSecret;

-(NSDictionary*) extractAccessTokenFromURL:(NSURL*)url;

-(NSDictionary*) extractAccessTokenFromString:(NSString*)str;

-(NSString*) encryptRequestWithSignatureBase:(NSString*)signatureBase andSigningKey:(NSString*)signingKey;

-(NSString*) getAccessTokenKey;

-(NSString*) getConsumerKey;

-(NSString*) getConsumerSecretKey;

-(NSString*) getTokenKey;

-(NSString*) getTokenSecretKey;

-(NSString*) getTokenVerifierKey;

@end
