//
//  TwitterManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/29/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "TwitterManager.h"
#import "AppDelegate.h"
#import "Deal.h"
#import "TwitterFeed.h"
#import "TwitterEngine.h"
#import "TwitterRequestObject.h"

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

#define TWITTER_SEARCH_RETURN_ENTITIES_KEY @"entities"
#define TWITTER_SEARCH_RETURN_HASHTAGS_KEY @"hashtags"
#define TWITTER_SEARCH_RETURN_HASHTAG_TEXT_KEY @"text"

#define TWITTER_SEARCH_RESULT_TYPE_DEFAULT @"recent"
#define TWITTER_SEARCH_COUNT_DEFAULT @"100"
#define TWITTER_SEARCH_GEOCODE_RADIUS_KM_DEFAULT @"0.20"

@interface TwitterManager ()
{
    BOOL userSignedIn;
}

typedef NS_ENUM(NSInteger, NSTwitterFilterType) {
    NSUSER_MENTION_FILTER = 0,
    NSHASHTAG_FILTER = 1,
    NSMENTIONS_FILTER = 2,
    NSCLEAR_FILTER = 3
};

@property (nonatomic, strong) TwitterFeed* twitterFeed;

@end

@implementation TwitterManager

-(instancetype)init
{
    self = [self initWithEngineHostName:nil andTwitterKeys:nil];
    
    if (!self) return nil;
    
    return self;
}

-(instancetype)initWithEngineHostName:(NSString *)hostName andTwitterKeys:(NSDictionary *)keys
{
    self = [super init];
    
    if(!self){
        return nil;
    }
    
    NSString* consumerK = NSLocalizedString(@"TWITTER_CONSUMER_KEY", nil);
    NSString* consumerSecretK = NSLocalizedString(@"TWITTER_CONSUMER_SECRET_KEY", nil);
    
    NSString* consumerKey = [keys valueForKey:consumerK];
    
    NSString* consumerSecret = [keys valueForKey:consumerSecretK];
    
    self.twitterFeed = [[TwitterFeed alloc] init];
    
    self.filteredTmpTwitterFeed = [[TwitterFeed alloc] init];
    
    self.engine = [[TwitterEngine alloc] initWithHostName:hostName andConsumerKey:consumerKey andConsumerSecret:consumerSecret];
    
    userSignedIn = NO;
    
    
    return self;
}

-(NSUInteger)totalTweetsCurrentlyLoaded
{
    return self.filteredTmpTwitterFeed.totalCount;
}

-(TWTRTweet *)tweetAtIndex:(NSUInteger)index
{        
    NSArray* currentTweets = [self.filteredTmpTwitterFeed getCurrentList];
    
    if (currentTweets != nil) {
        
        TWTRTweet* tweet = currentTweets[index];
        return tweet;
    }
    else{
        return nil;
    }
}

-(BOOL)accessTokenExists
{
    return [self.engine accessTokenExists];
}

-(BOOL)userSignedIn
{
    return userSignedIn;
}

-(void)twitterExtractTokenVerifierFromURL:(NSString *)URL
{
    [self.engine extractTokenVerifierFromURL:URL];
}

-(void)filterTwitterFeedBy:(NSInteger)filterType forEntity:(id)entity
{
    if ([entity isEqual:[NSNull null]]) {
        return;
    }
    
    switch (filterType) {
        case NSUSER_MENTION_FILTER:
            self.filteredTmpTwitterFeed = [self.engine filterTwitterFeed:self.twitterFeed ByUserMention:entity];
            break;
        case NSHASHTAG_FILTER:
            self.filteredTmpTwitterFeed = [self.engine filterTwitterFeed:self.twitterFeed ByHashtags:entity];
            NSLog(@"%lu", (unsigned long)self.filteredTmpTwitterFeed.totalCount);
            break;
        case NSMENTIONS_FILTER:
            self.filteredTmpTwitterFeed = [self.engine filterTwitterFeed:self.twitterFeed Mentions:entity];
            break;
        case NSCLEAR_FILTER:
            self.filteredTmpTwitterFeed = self.twitterFeed;
            break;
        default:
            break;
    }
    
    if (self.filteredTmpTwitterFeed) {
        [self.delegate twitterFilteredTweetsReturned];
    }

    
}

-(TwitterRequestObject *)constructTwitterRateLimitRequest:(NSArray *)query
{
    if (query == nil || query.count <= 0) {
        return [self.engine constructRateLimitRequest:nil];
    }
    else return [self.engine constructRateLimitRequest:query];
}

-(void)constructTwitterSearchRequestForDeal:(Deal *)deal addCompletion:(dataBlockResponse)completionBlock
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.databaseManager managerFetchGeocodeForAddress:deal.address additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        NSDictionary* geocodeResponse = (NSDictionary*)response;
        
        NSArray* coords = [geocodeResponse valueForKey:@"coordinates"];
        NSString* latitude = [coords valueForKey:@"lat"];
        NSString* longtitude = [coords valueForKey:@"lng"];
        NSLog(@"lng %@ nd lat %@",longtitude, latitude);
        NSLog(@"Deal %@", deal.addressString);
        CLLocation* location = [appDelegate.locationManager managerCreateLocationFromStringLongtitude:longtitude andLatitude:latitude];
        
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        
        NSMutableString* mutableQuery = [[NSMutableString alloc] initWithString:@""];
        
        NSString* query = mutableQuery.copy;
        
        params[TWITTER_SEARCH_QUERY_KEY] = query;
        
        NSString* geocode = [NSString stringWithFormat:@"%f,%f,%@km", coordinates.latitude, coordinates.longitude, TWITTER_SEARCH_GEOCODE_RADIUS_KM_DEFAULT];
        
        params[TWITTER_SEARCH_COUNT_KEY] = TWITTER_SEARCH_COUNT_DEFAULT;
        
        params[TWITTER_SEARCH_GEOCODE_KEY] = geocode;
        
        params[TWITTER_SEARCH_RESULT_TYPE_KEY] = TWITTER_SEARCH_RESULT_TYPE_DEFAULT;
        
        TwitterRequestObject* twitterRequest = [self.engine constructSearchRequestWithParams:params.copy];
        
        completionBlock(twitterRequest);
        
    }];

}

-(TwitterRequestObject *)constructTwitterTokenRequest
{
    return [self.engine constructTokenRequest:nil];
}

-(TwitterRequestObject *)constructTwitterAuthenticateRequest
{
    return [self.engine constructAuthenticateRequest];
}

-(TwitterRequestObject *)constructTwitterAccessTokenRequest
{
    return [self.engine constructAccessTokenRequest];
}

-(void)twitterTokenRequest:(TwitterRequestObject *)request
{
    if (!request) {
        return;
    }
    
    [self.engine requestToken:request WithCompletionHandler:^(BOOL tokenGranted) {
        
        if (tokenGranted) {
            [self.delegate twitterTokenGranted];
        }
        
    }];
}

-(void)twitterSignInAuthenticateRequest:(TwitterRequestObject *)request
{
    if (!request) {
        return;
    }
    
    [self.engine signInAuthenticateWithRequest:request CompletionHandler:^(NSString *HTMLResponse) {
        
        userSignedIn = YES;
        
        [self.delegate twitterHTMLResponseSuccess:HTMLResponse];
        
    }];
}

-(void)twitterAccessTokenRequest:(TwitterRequestObject *)request
{
    [self.engine accessTokenRequest:request CompletionHandler:^(BOOL accessTokenGranted) {
        
        if (accessTokenGranted) {
            
            [self.delegate twitterAccessTokenGranted];
        }
        
    }];
}

-(void)twitterSendGeneralRequest:(TwitterRequestObject *)twitterRequest
{
    [self.engine sendGeneralRequest:twitterRequest CompletionHandler:^(BOOL response, id responseObject) {
        
        if (response) {
            
            NSLog(@"%@", responseObject);
            
            [self.twitterFeed addListObject:responseObject];
            
            [self.filteredTmpTwitterFeed addListObject:responseObject];
            
            [self.delegate twitterGeneralRequestSucessful];
            
        }
        else [self.delegate twitterGeneralRequestFailed];
        
    }];
}

@end
