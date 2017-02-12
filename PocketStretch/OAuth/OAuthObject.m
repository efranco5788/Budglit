//
//  OAuthObject.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/6/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "OAuthObject.h"
#import "NSString+Encode.h"

#define OAUTH_AUTHORIZATION_HEADER_KEY @"Authorization"
#define OAUTH_SIGNATURE_METHOD @"HMAC-SHA1"
#define OAUTH_VERSION_1 @"1.0"
#define OAUTH_VERSION_2 @"2.0"
#define OAUTH @"OAuth"
#define DEFAULT_HTTP_METHOD @"POST"

#define OAUTH_ACCESS_TOKEN_KEY @"access_token"
#define OAUTH_CONSUMER_KEY @"oauth_consumer_key"
#define OAUTH_CONSUMER_SECRET_KEY @"oauth_consumer_secret"
#define OAUTH_TOKEN_KEY @"oauth_token"
#define OAUTH_TOKEN_SECRET_KEY @"oauth_token_secret"
#define OAUTH_TOKEN_VERIFIER @"oauth_verifier"

//NSInteger OAuthVersion;

@implementation OAuthObject

/*
-(void)setOAuthVersion:(NSInteger)version
{
    self.OAuthVersion = @(version);
}
*/
-(NSString *)generate_NONCEToken
{
    NSString* alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    
    NSMutableString* nonceTokenMutable = [NSMutableString stringWithCapacity:40];
    
    for (NSUInteger i = 0U; i < 40; i++) {
        uint32_t r = arc4random() % [alphabet length];
        unichar charcter = [alphabet characterAtIndex:r];
        [nonceTokenMutable appendFormat:@"%C", charcter];
    }
    
    NSString* nonceToken = [NSString stringWithString:nonceTokenMutable];
    
    return nonceToken;
}

-(NSString *)generate_Timestamp
{
    NSTimeInterval nowEpochSeconds = [[NSDate date] timeIntervalSince1970];
    
    NSString* epochSecs_String = [NSString stringWithFormat:@"%f", nowEpochSeconds];
    
    return epochSecs_String;
}

-(NSString *)getAccessTokenKey
{
    return OAUTH_ACCESS_TOKEN_KEY;
}

-(NSString *)getSignautreMethod
{
    return OAUTH_SIGNATURE_METHOD;
}

-(NSString *)getOAUTHVersion
{
    if ([self.OAuthVersion integerValue] == 1) {
        return OAUTH_VERSION_1;
    }
    else if ([self.OAuthVersion integerValue] == 2)
    {
        return OAUTH_VERSION_2;
    }
    else return OAUTH_VERSION_1;
}

-(NSString *)getAuthorizationHeaderKey
{
    return OAUTH_AUTHORIZATION_HEADER_KEY;
}

-(NSString *)getConsumerKey
{
    return OAUTH_CONSUMER_KEY;
}

-(NSString *)getConsumerSecretKey
{
    return OAUTH_CONSUMER_SECRET_KEY;
}

-(NSString *)getTokenKey
{
    return OAUTH_TOKEN_KEY;
}

-(NSString *)getTokenSecretKey
{
    return OAUTH_TOKEN_SECRET_KEY;
}

-(NSString *)getTokenVerifierKey
{
    return OAUTH_TOKEN_VERIFIER;
}

-(NSString *)encodeParameters:(NSDictionary *)parameters
{
    NSArray* sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray* sortedValues = [NSMutableArray array];
    
    for (NSString* key in sortedKeys) {
        [sortedValues addObject:[parameters objectForKey:key]];
    }

    NSMutableArray* encodedKeys = [[NSMutableArray alloc] init];
    NSMutableArray* encodedValues = [[NSMutableArray alloc] init];
    
    for (NSString* key in sortedKeys) {
        
        NSString* encodedString = [key encodeString:NSUTF8StringEncoding];
        
        [encodedKeys addObject:encodedString];
    }
    
    for (NSString* value in sortedValues) {
        
        NSString* encodedString = [value encodeString:NSUTF8StringEncoding];
        
        [encodedValues addObject:encodedString];
    }
    
    NSMutableString* encodedParameterString = [[NSMutableString alloc] init];
    
    for (NSUInteger index = 0; index < encodedKeys.count; index++) {
        
        NSString* key = [encodedKeys objectAtIndex:index];
        NSString* value = [encodedValues objectAtIndex:index];
        
        if (index == 0) {
            [encodedParameterString appendFormat:@"%@=%@", key, value];
        }
        else{
            [encodedParameterString appendFormat:@"&%@=%@", key, value];
        }
        
    }
    
    
    return encodedParameterString;
}

-(NSString *)constructAuthorizationString:(NSDictionary *)authorizationHeader
{
    NSMutableString* authorizationHeaderString = [[NSMutableString alloc] init];
    
    NSArray* sortedKeys = [[authorizationHeader allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSUInteger index = 0; index < sortedKeys.count; index++) {
        
        NSString* key = [sortedKeys objectAtIndex:index];
        
        NSString* encodedKey = [key encodeString:NSUTF8StringEncoding];
        
        NSString* encodedValue = [[authorizationHeader valueForKey:key] encodeString:NSUTF8StringEncoding];
        
        if(index == 0){
            [authorizationHeaderString appendFormat:@"%@ %@=\"%@\"", OAUTH,encodedKey, encodedValue];
        }
        else{
            [authorizationHeaderString appendFormat:@", %@=\"%@\"",encodedKey, encodedValue];
        }
    }
    
    return authorizationHeaderString;
}

-(NSString *)createSignatureBaseWithMethod:(NSString *)httpMethod andBaseURL:(NSString *)baseURL andParameterString:(NSString *)paramString andQuery:(NSString *)query
{
    NSString* method;
    
    if (httpMethod == nil) {
        method = DEFAULT_HTTP_METHOD;
    }
    else{
        method = [httpMethod uppercaseString];
    }
    
    NSString* encodedBaseURL = [baseURL encodeString:NSUTF8StringEncoding];
    
    NSString* encodedParamString = [paramString encodeString:NSUTF8StringEncoding];
    
    NSString* signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", method, encodedBaseURL, encodedParamString];
    
    return signatureBaseString;
    
}

-(NSString *)createSigningKeyConsumerSecret:(NSString *)consumerSecret andTokenSecret:(NSString *)tokenSecret
{
    NSString* signingKey;
    
    if (consumerSecret != nil && tokenSecret != nil) {
        
        NSString* encodedConsumerSecret = [consumerSecret encodeString:NSUTF8StringEncoding];
        
        NSString* encodedTokenSecret = [tokenSecret encodeString:NSUTF8StringEncoding];
        
        signingKey = [NSString stringWithFormat:@"%@&%@",encodedConsumerSecret, encodedTokenSecret];
    }
    else if (consumerSecret != nil && tokenSecret == nil){
        
        NSString* encodedConsumerSecret = [consumerSecret encodeString:NSUTF8StringEncoding];
        
        signingKey = [NSString stringWithFormat:@"%@&",encodedConsumerSecret];
        
    }
    else{
        signingKey = nil;
    }
    
    return signingKey;
}

-(NSDictionary*)extractAccessTokenFromURL:(NSURL *)url
{
    NSDictionary* accessTokn;
    
    return accessTokn;
}

-(NSDictionary*)extractAccessTokenFromString:(NSString*)str
{
    NSDictionary* accessTokn;
    
    if (!str) {
        return nil;
    }
    
    NSArray* qryFragment = [str componentsSeparatedByString:@"#"];
    
    NSString* urlFragmnt = [qryFragment objectAtIndex:1];
    
    NSArray* fragmntBreakdown = [urlFragmnt componentsSeparatedByString:@"="];
    
    NSString* key = [fragmntBreakdown objectAtIndex:0];
    NSString* value = [fragmntBreakdown objectAtIndex:1];
    
    if (key && value) {
        accessTokn = [NSDictionary dictionaryWithObject:[value copy] forKey:[key copy]];
    }
    else accessTokn = nil;
    
    return accessTokn;
}

-(NSString *)encryptRequestWithSignatureBase:(NSString *)signatureBase andSigningKey:(NSString *)signingKey
{
    NSString* encryptedSignature = [NSString hash:signatureBase secret:signingKey];
    
    return encryptedSignature;
}

@end
