//
//  InstagramEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "InstagramEngine.h"

#define CURRENT_OAUTH_VERSION @"2"
#define API_REDIRECT_URL_OAUTH_PATH @"/oauth/authorize/"
#define API_REDIRECT_CLIENT_ID_URL_FRAGMENT @"?client_id="
#define API_REDIRECT_URI_FRAGMENT @"&redirect_uri="
#define API_REDIRECT_URL_RESPONSE_TYPE_FRAGMENT @"&response_type="
#define API_REDIRECT_URL_RESPONSE_TYPE @"token"
#define API_SCOPE_FRAGMENT @"scope="
#define API_SCOPE_FRAGMENT_PUBLIC_CONTENT @"public_content"
#define API_SCOPE_FRAGMENT_FOLLOWER_LIST @"follower_list"
#define API_SIGNED_PARAMETER_KEY @"sig="
#define API_ACCESS_RECENT_MEDIA @"/v1/tags/nofilter/media/recent?"
#define API_ACCESS_USER_MEDIA @"/v1/users/self/media/recent/?"
#define API_RESPONSE_CODE_META @"meta"
#define API_RESPONSE_CODE_CODE @"code"
#define REDIRECT_URI @"https://www.budglit.com/api/instagram/token_handler"

//https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code
//https://api.instagram.com/v1/tags/nofilter/media/recent?access_token=ACCESS_TOKEN
//https://api.instagram.com/v1/users/self/media/recent/?access_token=ACCESS-TOKEN

@interface InstagramEngine()
@property (strong, nonatomic) NSString* clientID;
@property (strong, nonatomic) NSString* clientSecret;
@property (strong, nonatomic) NSDictionary* accessToken;
@end

@implementation InstagramEngine

-(instancetype)init
{
    self = [self initWithHostName:nil andClientID:nil andClientSecret:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithHostName:(NSString *)hostName
{
    self = [self initWithHostName:hostName andClientID:nil andClientSecret:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithHostName:(NSString *)hostName andClientID:(NSString *)cID andClientSecret:(NSString *)secret
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }

    [self.OAuth setOAuthVersion:CURRENT_OAUTH_VERSION];
    
    self.clientID = [[NSString alloc] initWithString:cID];
    
    self.clientSecret = [[NSString alloc] initWithString:secret];
    
    return self;
}

-(NSString*)constructAuthorizationURLString
{
    NSMutableString* constructedURL = [[NSMutableString alloc] initWithString:self.baseURLString];
    
    [constructedURL appendString:API_REDIRECT_URL_OAUTH_PATH];
    
    [constructedURL appendString:API_REDIRECT_CLIENT_ID_URL_FRAGMENT];
    
    [constructedURL appendString:self.clientID];
    
    [constructedURL appendString:API_REDIRECT_URI_FRAGMENT];
    
    [constructedURL appendString:REDIRECT_URI];
    
    [constructedURL appendString:API_REDIRECT_URL_RESPONSE_TYPE_FRAGMENT];
    
    [constructedURL appendString:API_REDIRECT_URL_RESPONSE_TYPE];
    
    NSString* urlString = [constructedURL copy];
    
    return urlString;
}

-(NSString *)constructUserURLString
{
    NSMutableString* constructedURL = [[NSMutableString alloc] initWithString:self.baseURLString];
    
    [constructedURL appendString:API_ACCESS_USER_MEDIA];
    
    [constructedURL appendString:[self.OAuth getAccessTokenKey]];
    
    NSString* tokn = [self.accessToken valueForKey:[self.OAuth getAccessTokenKey]];
    
    [constructedURL appendString:@"="];
    
    [constructedURL appendString:tokn];
    
    NSString* urlStr = [constructedURL copy];
    
    return urlStr;
}


-(NSString *)constructRecentMediaURLString
{
    NSMutableString* constructedURL = [[NSMutableString alloc] initWithString:self.baseURLString];
    
    [constructedURL appendString:API_ACCESS_RECENT_MEDIA];
    
    [constructedURL appendString:[self.OAuth getAccessTokenKey]];
    
    NSString* tokn = [self.accessToken valueForKey:[self.OAuth getAccessTokenKey]];
    
    [constructedURL appendString:@"="];
    
    [constructedURL appendString:tokn];
    
    NSString* urlStr = [constructedURL copy];
    
    return urlStr;
}

-(NSString *)getAPI_Redirect_URI
{
    return REDIRECT_URI;
}

-(void)retrieveAccessTokenFromString:(NSString *)urlStr WithCompletionHandler:(OAuthTokenRequestResponse)completionBlock
{
    NSDictionary* accessTokn;
    
    accessTokn = [self.OAuth extractAccessTokenFromString:urlStr];
    
    if (self.accessToken) {
        self.accessToken = nil;
        
        completionBlock(NO);
    }
    
    self.accessToken = accessTokn;
    
    completionBlock(YES);
}

-(BOOL)accessTokenExists
{
    if (self.accessToken == NULL) {
        return NO;
    }
    
    NSString* tokn = [self.accessToken valueForKey:API_REDIRECT_URL_RESPONSE_TYPE];
    
    if (tokn.length == 0) {
        return NO;
    }
    
    if ([tokn stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
        return NO;
    }
    
    return YES;
}

-(void)sendInstagramRequest:(NSString *)strURL withCompletionHandler:(InstagramResponseResult)completionBlock
{
    //NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSURL* base = [NSURL URLWithString:self.baseURLString];
    
    //self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:base sessionConfiguration:config];
    
    //self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self getRequestToPath:strURL parameters:nil addCompletion:^(id responseObject) {
        
        NSDictionary* responseDic = (NSDictionary*) responseObject;
        
        NSDictionary* objDict = responseDic[API_RESPONSE_CODE_META];
        
        NSString* codeString = [objDict valueForKey:API_RESPONSE_CODE_CODE];
        
        NSInteger code = codeString.integerValue;
        
        NSLog(@"Resposne %ld", (long)code);
        
        if (code == 200) {
            
            completionBlock(responseObject);
        }
        else if (code == 400)
        {
            NSLog(@"Failed");
            completionBlock(nil);
        }
        else completionBlock(nil);
        
    }];
    
    /*
    [self.sessionManager GET:strURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSDictionary* responseDic = (NSDictionary*) responseObject;
        
        NSDictionary* objDict = responseDic[API_RESPONSE_CODE_META];
        
        NSString* codeString = [objDict valueForKey:API_RESPONSE_CODE_CODE];
        
        NSInteger code = codeString.integerValue;
        
        NSLog(@"Resposne %ld", (long)code);
        
        if (code == 200) {
            
            completionBlock(responseObject);
        }
        else if (code == 400)
        {
            NSLog(@"Failed");
            completionBlock(nil);
        }
        else completionBlock(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error %@", error);
        
    }];
     */
    
}

@end
