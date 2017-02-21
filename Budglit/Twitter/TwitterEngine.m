//
//  TwitterEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "TwitterEngine.h"
#import "NSString+Encode.h"
#import "Tweet.h"
//#import "TwitterKit/TwitterKit.h"

#define CURRENT_OAUTH_VERSION @"1.0"
#define OAUTH_REQUEST_TOKEN_URL_PATH @"/oauth/request_token"
#define OAUTH_AUTHENTICATE_URL_PATH @"/oauth/authenticate"
#define OAUTH_AUTHORIZE_URL_PATH @"/oauth/authorize"
#define OAUTH_ACCESS_TOKEN_URL_PATH @"/oauth/access_token"

#define TWITTER_SEARCH_URL_PATH @"/1.1/search/tweets.json"
#define TWITTER_RATE_LIMIT_URL_PATH @"/1.1/application/rate_limit_status.json"

#define TWITTER_RATE_TIME_LIMIT 180
#define TWITTER_HTTP_RESPONSE_RATE_TIME_LIMIT_REMAINING @"x-rate-limit-remaining"

#define TWITTER_SEARCH_QUERY_KEY @"q"
#define TWITTER_SEARCH_GEOCODE_KEY @"geocode"
#define TWITTER_SEARCH_LANG_KEY @"lang"
#define TWITTER_SEARCH_LOCALE_KEY @"locale"
#define TWITTER_SEARCH_RESULT_TYPE_KEY @"result_type"
#define TWITTER_SEARCH_COUNT_KEY @"count"
#define TWITTER_SEARCH_UNTIL_KEY @"until"
#define TWITTER_SEARCH_SINCE_ID_KEY @"since_id"
#define TWITTER_SEARCH_MAX_ID_KEY @"max_id"
#define TWITTER_SEARCH_INCLUDE_ENTITIES_KEY @"include_entities"
#define TWITTER_SEARCH_STATUSES_KEY @"statuses"
#define TWITTER_SEARCH_METADATA_KEY @"search_metadata"

#define SIGNED_IN_SCREEN_NAME @"screen_name"

#define CALLBACK_URL @"https://www.budglit.com/twitter/token_handler.php"


@interface TwitterEngine()

@property (strong, nonatomic) NSDictionary* consumerKey;
@property (strong, nonatomic) NSDictionary* tokenRequest;
@property (strong, nonatomic) NSDictionary* tokenAccess;

@end


@implementation TwitterEngine

-(id)init
{
    return [self initWithHostName:nil andConsumerKey:nil andConsumerSecret:nil];
}

-(id)initWithHostName:(NSString*)hostName andConsumerKey:(NSString*)key andConsumerSecret:(NSString*)secret
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }

    self.tokenRequest = [[NSDictionary alloc] init];
    self.tokenAccess = [[NSDictionary alloc] init];
    self.twitterRequestHistory = [[NSMutableArray alloc] init];
    self.consumerKey = [[NSDictionary alloc] init];
    [self.OAuth setOAuthVersion:CURRENT_OAUTH_VERSION];
    
    NSString* trimmedKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![key isEqual:nil] || !([trimmedKey length] == 0)) {
        
        NSMutableDictionary* consumerKeyInfo = [[NSMutableDictionary alloc] init];
        
        NSString* consumerKey = [self.OAuth getConsumerKey];
        NSString* consumerSecretKey = [self.OAuth getConsumerSecretKey];
        
        [consumerKeyInfo setObject:key forKey:consumerKey];
        [consumerKeyInfo setObject:secret forKey:consumerSecretKey];
        
        self.consumerKey = consumerKeyInfo;
    }
    
        
    return self;
    
}

-(void) recordRequestToken:(NSString*)token andRequestTokenSecret:(NSString*)tokenSecret
{
    NSMutableDictionary* tokenInfo = [[NSMutableDictionary alloc] init];
    
    NSString* tokenKey = [self.OAuth getTokenKey];
    NSString* tokenSecretKey = [self.OAuth getTokenSecretKey];
    
    [tokenInfo setValue:token forKey:tokenKey];
    [tokenInfo setValue:tokenSecret forKey:tokenSecretKey];
    
    self.tokenRequest = tokenInfo;
}

-(void) recordAccessToken:(NSString*)token andAccessTokenSecret:(NSString*)tokenSecret
{
    NSMutableDictionary* tokenInfo = [[NSMutableDictionary alloc] init];
    
    NSString* tokenKey = [self.OAuth getTokenKey];
    NSString* tokenSecretKey = [self.OAuth getTokenSecretKey];
    
    [tokenInfo setValue:token forKey:tokenKey];
    [tokenInfo setValue:tokenSecret forKey:tokenSecretKey];
    
    self.tokenAccess = tokenInfo;
}


-(void)recordTokenVerifier:(NSString*)verifier
{
    NSMutableDictionary* tokenInfo = self.tokenRequest.mutableCopy;
    
    if (tokenInfo) {
        NSString* key = [self.OAuth getTokenVerifierKey];
        
        [tokenInfo setValue:verifier forKey:key];
        
        self.tokenRequest = tokenInfo;
    }
}

-(BOOL)accessTokenExists
{
    NSUInteger tokenCount = self.tokenAccess.count;
    
    if (tokenCount < 1) {
        return FALSE;
    }
    else return TRUE;
}

-(void)extractTokenVerifierFromURL:(NSString *)URL
{
    NSString* tokenVerifierKey = [self.OAuth getTokenVerifierKey];
    
    NSArray* queryInfo = [URL componentsSeparatedByString:@"?"];
    
    NSString* URLQuery = [queryInfo objectAtIndex:1];
    
    NSArray* parameters = [URLQuery componentsSeparatedByString:@"&"];
    
    NSString* key;
    NSString* value;
    
    for (NSString* string in parameters) {
        NSArray* keyValueSplit = [string componentsSeparatedByString:@"="];
        
        key = [keyValueSplit objectAtIndex:0];
        
        if ([key isEqualToString:tokenVerifierKey]) {
            value = [keyValueSplit objectAtIndex:1];
            
            [self recordTokenVerifier:value];
        }
    }
}

-(NSDictionary *)getTokenVerifier
{
    
    NSString* key = [self.OAuth getTokenVerifierKey];
    NSString* value = [self.tokenRequest valueForKey:key];
    
    NSDictionary* verifierInfo = [NSDictionary dictionaryWithObject:value forKey:key];
    
    return verifierInfo;
}

-(TwitterFeed *)filterTwitterFeed:(TwitterFeed *)feed ByUserMention:(NSString *)username
{
    TwitterFeed* filteredFeed = [[TwitterFeed alloc] init];
    
    if(!feed)
    {
        return filteredFeed;
    }
    
    if (!username) {
        return filteredFeed;
    }
    
    if (feed.totalCount == 0) {
        return filteredFeed;
    }
    
    NSMutableArray* tweets = feed.list.mutableCopy;
    
    username = [username lowercaseString];
    
    NSString* searchMention = [NSString stringWithFormat:@"@%@", username];
    
    for (NSInteger i = 0; i < tweets.count; i++) {
        
        Tweet* currentTwt = [tweets objectAtIndex:i];
        
        //NSString* twtTxt = currentTwt.text.copy;
        
        
        NSString* twtTxt = @"Hello";
        twtTxt = twtTxt.lowercaseString;
        
        if ([twtTxt containsString:searchMention]) {
            [filteredFeed addTweetToFeed:currentTwt];
            [tweets removeObject:currentTwt];
        }
        
    }
    
    /*
    for (int i = 0; i < tweets.count; i++){
        
        Tweet* currentTwt = [tweets objectAtIndex:i];
        
        NSString* twtTxt = currentTwt.text.copy;
        
        twtTxt = twtTxt.lowercaseString;
        
        if ([twtTxt rangeOfString:username].location != NSNotFound) {
            [filteredFeed addTweetToFeed:currentTwt];
            [tweets removeObjectAtIndex:i];
        }
        
    }
    */
    return filteredFeed;
}

-(TwitterFeed *)filterTwitterFeed:(TwitterFeed *)feed ByHashtags:(NSString *)hashtag
{
    TwitterFeed* filteredFeed = [[TwitterFeed alloc] init];
    
    if (!feed) {
        return filteredFeed;
    }
    
    if (!hashtag) {
        return filteredFeed;
    }
    
    if (feed.totalCount== 0) {
        return filteredFeed;
    }
    
    NSMutableArray* tweets = [feed.list mutableCopy];
    
    hashtag = [hashtag lowercaseString];
    
    NSString* searchTag = [NSString stringWithFormat:@"#%@", hashtag];
    
    for (NSInteger count = 0; count < tweets.count; count++) {
        
        Tweet* currentTwt = [tweets objectAtIndex:count];
        
        //NSString* twtTxt = currentTwt.text.copy;
        
        
        NSString* twtTxt = @"Hello";
        twtTxt = twtTxt.lowercaseString;
        
        if ([twtTxt containsString:searchTag]) {
            [filteredFeed addTweetToFeed:currentTwt];
            [tweets removeObject:currentTwt];
        }
    }
    
    /*
    for (int count = 0; count < tweets.count; count++) {
        
        Tweet* currentTwt = [tweets objectAtIndex:count];
        
        NSString* twtTxt = currentTwt.text.copy;
        
        twtTxt = twtTxt.lowercaseString;
        
        for (id tag in currentTwt.hashtags) {
            
            if ([tag isKindOfClass:[NSString class]]) {
                
                if ([twtTxt rangeOfString:hashtag].location != NSNotFound) {
                    [filteredFeed addTweetToFeed:currentTwt];
                    [tweets removeObjectAtIndex:count];
                }
                
            }
        }
        
        
    }
    */
    
    return filteredFeed;
}

-(TwitterFeed *)filterTwitterFeed:(TwitterFeed *)feed Mentions:(NSString *)mention
{
    TwitterFeed* filteredFeed = [[TwitterFeed alloc] init];
    
    if(!feed)
    {
        return filteredFeed;
    }
    
    if (!mention) {
        return filteredFeed;
    }
    
    if (feed.totalCount == 0) {
        return filteredFeed;
    }
    
    NSMutableArray* tweets = [feed.list mutableCopy];
    
    mention = [mention lowercaseString];
    
    NSCharacterSet* whitespaces = [NSCharacterSet whitespaceCharacterSet];
    
    NSPredicate* noEmptyString = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray* parts = [mention componentsSeparatedByCharactersInSet:whitespaces];
    
    NSArray* filteredArray = [parts filteredArrayUsingPredicate:noEmptyString];
    
    for (NSString* substring in filteredArray) {
        
        for (int count = 0; count < tweets.count; count++) {
            
            Tweet* currentTwt = [tweets objectAtIndex:count];
            
            //NSString* twtTxt = currentTwt.text.copy;
            
            
            NSString* twtTxt = @"Hello";
            
            twtTxt = twtTxt.lowercaseString;
            
            if ([twtTxt rangeOfString:substring].location != NSNotFound) {
                [filteredFeed addTweetToFeed:currentTwt];
                [tweets removeObjectAtIndex:count];
            }
            
        }
        
    }
    
    return filteredFeed;
}

-(TwitterRequestObject*)constructAuthorizationParam:(TwitterRequestObject *)request
{
    NSString* consumer_key = [self.consumerKey valueForKey:[self.OAuth getConsumerKey]];
    
    NSString* nonce = [self.OAuth generate_NONCEToken];
    
    NSString* signatureMethod = [self.OAuth getSignautreMethod];
    
    NSString* timestamp = [self.OAuth generate_Timestamp];
    
    NSString* oauthVersion = [self.OAuth getOAUTHVersion];
    
    NSString* callbackURL = CALLBACK_URL;
    
    NSString* encodedCallbackURL = [callbackURL encodeString:NSUTF8StringEncoding];
    
    request.encodedCallbackURL = encodedCallbackURL;
    
    NSMutableArray* keys;
    
    NSMutableArray* values;
    
    if (self.tokenRequest.count <= 0)
    {
        
        keys = [NSMutableArray arrayWithObjects:
                @"oauth_callback",
                @"oauth_consumer_key",
                @"oauth_nonce",
                @"oauth_signature_method",
                @"oauth_timestamp",
                @"oauth_version", nil];
        
        values = [NSMutableArray arrayWithObjects:
                  callbackURL,
                  consumer_key,
                  nonce,
                  signatureMethod,
                  timestamp,
                  oauthVersion,
                  nil];
    }
    else
    {
        NSString* tokenKey = [self.OAuth getTokenKey];
        NSString* token;
        
        if (self.tokenAccess.count <= 0) {
            
            token = [self.tokenRequest objectForKey:tokenKey];
            
        }
        else{
            
            token = [self.tokenAccess objectForKey:tokenKey];
            
        }
        
        keys = [NSMutableArray arrayWithObjects:
                @"oauth_consumer_key",
                @"oauth_nonce",
                @"oauth_signature_method",
                @"oauth_timestamp",
                tokenKey,
                @"oauth_version", nil];
        
        values = [NSMutableArray arrayWithObjects:
                  consumer_key,
                  nonce,
                  signatureMethod,
                  timestamp,
                  token,
                  oauthVersion,
                  nil];
    }
    
    
    NSDictionary* authorizationParams = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    request.initialRequestAuthorizationHeader = authorizationParams;
    
    NSString* signatureBase = [self twitterGenerateSignatureBaseForRequest:request];
    
    NSString* signingKey = [self createSigningKey];
    
    NSString* encryptedRequestSignature = [self encryptWithSignatureBase:signatureBase andSigningKey:signingKey];
    
    request.requestSignatureBase = signatureBase;
    
    request.requestSigningKey = signingKey;
    
    request.requestEncryptedSignature = encryptedRequestSignature;
    
    NSMutableDictionary* initialParams = [NSMutableDictionary dictionaryWithDictionary:request.initialRequestAuthorizationHeader];
    
    [initialParams setObject:encryptedRequestSignature forKey:@"oauth_signature"];
    
    request.finalRequestAuthorizationHeader = initialParams;
    
    return request;
}

-(TwitterRequestObject *)constructTokenRequest:(NSDictionary *)additionalParams
{
    TwitterRequestObject* tokenRequest = [[TwitterRequestObject alloc] init];
    
    tokenRequest.urlPath = OAUTH_REQUEST_TOKEN_URL_PATH;
    
    [tokenRequest setHttpMethod:@"POST"];
    
    [self constructAuthorizationParam:tokenRequest];
    
    [self.twitterRequestHistory addObject:tokenRequest];
    
    return tokenRequest;
}

-(TwitterRequestObject *)constructAuthenticateRequest
{
    TwitterRequestObject* request = [[TwitterRequestObject alloc] init];
    
    request.urlPath = OAUTH_AUTHENTICATE_URL_PATH;
    
    [request setHttpMethod:@"GET"];
    
    if (self.tokenRequest.count >= 1) {
        
        NSMutableDictionary* queryInfo = [[NSMutableDictionary alloc] init];
        
        NSString* tokenKey = [self.OAuth getTokenKey];
        
        NSString* token = [self.tokenRequest valueForKey:tokenKey];
        
        [queryInfo setObject:token forKey:tokenKey];
        
        request.query = queryInfo;
        
    }
    
    [self.twitterRequestHistory addObject:request];
    
    return request;
}

-(TwitterRequestObject *)constructAccessTokenRequest
{
    TwitterRequestObject* tokenAccessRequest = [[TwitterRequestObject alloc] init];
    
    [tokenAccessRequest setHttpMethod:@"POST"];
    
    tokenAccessRequest.urlPath = OAUTH_ACCESS_TOKEN_URL_PATH;
    
    [self constructAuthorizationParam:tokenAccessRequest];
    
    NSString* tokenVerifierKey = [self.OAuth getTokenVerifierKey];
    
    NSString* token_verifier = [self.tokenRequest valueForKey:tokenVerifierKey];
    
    NSDictionary* param = [NSDictionary dictionaryWithObject:token_verifier forKey:tokenVerifierKey];
    
    tokenAccessRequest.query = param;
    
    [self.twitterRequestHistory addObject:tokenAccessRequest];
    
    return tokenAccessRequest;
}

-(TwitterRequestObject*)constructSearchRequestWithParams:(NSDictionary*)params
{
    TwitterRequestObject* searchRequest = [[TwitterRequestObject alloc] init];
    
    [searchRequest setHttpMethod:@"GET"];
    
    searchRequest.urlPath = TWITTER_SEARCH_URL_PATH;
    
    if (params.count <= 0 || params == nil) {
        searchRequest.query = nil;
        searchRequest.additonalParams = nil;
    }
    else {
        
        NSArray* keys = params.allKeys;
        NSMutableDictionary* mutableAdditionalParam = [[NSMutableDictionary alloc] init];
        
        for (NSString* key in keys) {
            
            NSString* value = [params valueForKey:key];
            
            if ([key isEqualToString:TWITTER_SEARCH_QUERY_KEY]) {
                
                NSDictionary* searchQuery = [NSDictionary dictionaryWithObject:value forKey:key];
                
                searchRequest.query = searchQuery;
            }
            else [mutableAdditionalParam setObject:value forKey:key];
            
        }
        
        searchRequest.additonalParams = mutableAdditionalParam.copy;
        
    }
    
    [self constructAuthorizationParam:searchRequest];
    
    [self.twitterRequestHistory addObject:searchRequest];
    
    return searchRequest;
}

-(TwitterRequestObject*)constructRateLimitRequest:(NSArray *)queryFilter
{
    TwitterRequestObject* rateLimitRequest = [[TwitterRequestObject alloc] init];
    
    [rateLimitRequest setHttpMethod:@"GET"];
    
    [rateLimitRequest setUrlPath:TWITTER_RATE_LIMIT_URL_PATH];
    
    if (queryFilter.count >= 1) {
        
    }
    else rateLimitRequest.query = nil;
    
    [self constructAuthorizationParam:rateLimitRequest];
    
    [self.twitterRequestHistory addObject:rateLimitRequest];
    
    return rateLimitRequest;
}

-(NSString*)twitterGenerateSignatureBaseForRequest:(TwitterRequestObject *)twitterRequest
{
    NSString* parameterString;
    
    NSString* baseURL = [self constructURLPath:nil API:twitterRequest.urlPath Query:twitterRequest.query AdditionalParameters:twitterRequest.additonalParams HTTPMethod:twitterRequest.httpMethod PortNumber:0 SSL:YES];
    
    NSString* signatureBase;
    
    if (twitterRequest.query.count > 0) {
    
        NSMutableDictionary* authParams = twitterRequest.initialRequestAuthorizationHeader.mutableCopy;
    
        [authParams addEntriesFromDictionary:twitterRequest.query];
        
        if (twitterRequest.additonalParams.count > 0) {
            [authParams addEntriesFromDictionary:twitterRequest.additonalParams];
        }
    
        parameterString = [self.OAuth encodeParameters:authParams];
    
        signatureBase = [self.OAuth createSignatureBaseWithMethod:twitterRequest.httpMethod andBaseURL:baseURL andParameterString:parameterString andQuery:nil];
    
    }
    else{
    
        parameterString = [self.OAuth encodeParameters:twitterRequest.initialRequestAuthorizationHeader];
    
        signatureBase = [self.OAuth createSignatureBaseWithMethod:twitterRequest.httpMethod andBaseURL:baseURL andParameterString:parameterString andQuery:nil];
    }
    
    return signatureBase;
    
    return nil;
}

-(NSString *)createSigningKey
{
    NSString* signingKey;
    
    NSString* consumerSecretKey = [self.OAuth getConsumerSecretKey];
    
    NSString* consumerSecret = [self.consumerKey valueForKey:consumerSecretKey];
    
    if (self.tokenRequest.count <= 0) {
        
        signingKey = [self.OAuth createSigningKeyConsumerSecret:consumerSecret andTokenSecret:nil];
        
    }
    else{
        
        NSString* tokenSecretKey = [self.OAuth getTokenSecretKey];
        
        NSString* tokenSecret;
        
        //check if access token has been given.
        if (self.tokenAccess.count <= 0) {
            
            tokenSecret = [self.tokenRequest valueForKey:tokenSecretKey];
            
        }
        else{
            
            tokenSecret = [self.tokenAccess valueForKey:tokenSecretKey];
            
        }
        
        signingKey = [self.OAuth createSigningKeyConsumerSecret:consumerSecret andTokenSecret:tokenSecret];
    }
    
    return signingKey;
}

-(NSString *)encryptWithSignatureBase:(NSString *)signatureBase andSigningKey:(NSString *)signingKey
{
    NSString* encryptedRequestSignature = [self.OAuth encryptRequestWithSignatureBase:signatureBase andSigningKey:signingKey];
    
    return encryptedRequestSignature;
}


-(void)requestToken:(TwitterRequestObject *)request WithCompletionHandler:(OAuthTokenRequestResponse)completionBlock
{
    NSString* authHeaderValue = [self.OAuth constructAuthorizationString:request.finalRequestAuthorizationHeader];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL* baseURL = [NSURL URLWithString:self.baseURLString];
    
    AFHTTPSessionManager* sessionMangr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    
    sessionMangr.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [sessionMangr.requestSerializer setValue:authHeaderValue forHTTPHeaderField:@"Authorization"];
    
    [sessionMangr.requestSerializer setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    
    [sessionMangr.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    sessionMangr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [sessionMangr POST:OAUTH_REQUEST_TOKEN_URL_PATH parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSString* responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSArray* splitResponse = [responseString componentsSeparatedByString:@"&"];
        
        NSString* tokenRequestValue = [[NSString alloc] init];
        NSString* tokenRequestSecretValue = [[NSString alloc] init];
        
        for (NSString* string in splitResponse) {
            NSArray* keyValueSplit = [string componentsSeparatedByString:@"="];
            
            NSString* key = [keyValueSplit objectAtIndex:0];
            
            NSString* tokenKey = [self.OAuth getTokenKey];
            NSString* tokenSecretKey = [self.OAuth getTokenSecretKey];
            
            if ([key isEqualToString:tokenKey])
            {
                tokenRequestValue = [keyValueSplit objectAtIndex:1];
            }
            else if ([key isEqualToString:tokenSecretKey])
            {
                tokenRequestSecretValue = [keyValueSplit objectAtIndex:1];
            }
            
            [self recordRequestToken:tokenRequestValue andRequestTokenSecret:tokenRequestSecretValue];
            
        }
        
        completionBlock(TRUE);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
    }];

}

-(void)signInAuthenticateWithRequest:(TwitterRequestObject *)twitterRequest CompletionHandler:(OAuthTwitterResponse)completionBlock
{
    if (twitterRequest == nil) {
            NSLog(@"no request was found");
            return;
    }
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.sessionManager GET:twitterRequest.urlPath parameters:twitterRequest.query progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSHTTPURLResponse* HTTPTaskResponse = (NSHTTPURLResponse*) task.response;
        
        if (HTTPTaskResponse.statusCode == 200) {
            
            NSString* HTTP_responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            completionBlock(HTTP_responseString);
        }
        else completionBlock(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
    }];
    
}

-(void)accessTokenRequest:(TwitterRequestObject *)twitterRequest CompletionHandler:(OAuthAccessTokenRequestResponse)completionBlock
{
    if (twitterRequest == nil) {
        NSLog(@"no request was found");
        return;
    }
    
    NSString* authValue = [self.OAuth constructAuthorizationString:twitterRequest.finalRequestAuthorizationHeader];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL* baseURL = [NSURL URLWithString:self.baseURLString];
    
    AFHTTPSessionManager* sessionMangr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    
    sessionMangr.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [sessionMangr.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    [sessionMangr.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    sessionMangr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [sessionMangr POST:OAUTH_ACCESS_TOKEN_URL_PATH parameters:twitterRequest.query progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSHTTPURLResponse* HTTPTaskResponse = (NSHTTPURLResponse*) task.response;
        
        if (HTTPTaskResponse.statusCode == 200) {
            
            NSString* response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            NSArray* responseInfo = [response componentsSeparatedByString:@"&"];
            
            NSString* accessTokenValue = [[NSString alloc] init];
            NSString* accessTokenSecretValue = [[NSString alloc] init];
            NSString* screenName = [[NSString alloc] init];
            
            for (NSString* HTTPResponse in responseInfo) {
                
                NSString* tokenKey = [self.OAuth getTokenKey];
                NSString* tokenSecretKey = [self.OAuth getTokenSecretKey];
                
                NSArray* keyValuePair = [HTTPResponse componentsSeparatedByString:@"="];
                NSString* key = [keyValuePair firstObject];
                
                if ([key isEqualToString:tokenKey])
                {
                    accessTokenValue = [keyValuePair lastObject];
                }
                else if ([key isEqualToString:tokenSecretKey])
                {
                    accessTokenSecretValue = [keyValuePair lastObject];
                }
                else if ([key isEqualToString:SIGNED_IN_SCREEN_NAME])
                {
                    screenName = [keyValuePair lastObject];
                }
                
            }
            
            [self recordAccessToken:accessTokenValue andAccessTokenSecret:accessTokenSecretValue];
            
            completionBlock(TRUE);
            
        }
        else completionBlock(FALSE);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
        completionBlock(FALSE);
        
    }];
    
    
}

-(void)sendGeneralRequest:(TwitterRequestObject *)twitterRequest CompletionHandler:(TwitterResponseResult)completionBlock
{
    if (twitterRequest == nil) {
        return;
    }
    
    NSString* value = [self.OAuth constructAuthorizationString:twitterRequest.finalRequestAuthorizationHeader];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    config.HTTPAdditionalHeaders = @{@"Authorization": value};
    
    NSURL* base = [NSURL URLWithString:self.baseURLString];
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:base sessionConfiguration:config];
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params addEntriesFromDictionary:twitterRequest.query];
    
    if (twitterRequest.additonalParams) {
        [params addEntriesFromDictionary:twitterRequest.additonalParams];
    }
    
    if ([twitterRequest.httpMethod isEqualToString:@"GET"]) {
        
        [self.sessionManager GET:twitterRequest.urlPath parameters:params.copy progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self addToRequestHistory:task];
            
            NSHTTPURLResponse* HTTPTaskResponse = (NSHTTPURLResponse*) task.response;
            
            if (HTTPTaskResponse.statusCode == 200) {
                
                completionBlock(YES, responseObject);
                
            }
            else if (HTTPTaskResponse.statusCode == 429) {
                
                NSLog(@"Limit of request has exceeded");
                
                completionBlock(NO, nil);
                
            }
            else {
                
                //NSString* twitterTimeLimitValue = [HTTPTaskResponse valueForKey:TWITTER_HTTP_RESPONSE_RATE_TIME_LIMIT_REMAINING];
                
                NSLog(@"An error occured. Returned response %ld", (long)HTTPTaskResponse.statusCode);
                
                completionBlock(NO, nil);
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [self logFailedRequest:task];
            
        }];
        
    }
    else
    {
        
    }
    
}

@end
