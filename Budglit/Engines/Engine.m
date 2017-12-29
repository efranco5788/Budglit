//
//  Engine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

#define KEY_SESSION_COOKIES @"sessionCookies"

@interface Engine()

@property (nonatomic, strong) NSArray* requestHistory;
@property (nonatomic, strong) NSArray* failedRequestHistory;

@end

@implementation Engine
@synthesize baseURLString = _baseURLString;

-(instancetype) init
{
    return [self initWithHostName:nil];
}

-(instancetype) initWithHostName:(NSString*)hostName
{    
    self = [super init];
    
    if (!self) return nil;
    
    _baseURLString = hostName;
    
    NSURL* baseURL = [NSURL URLWithString:_baseURLString];
    
    self.OAuth = [[OAuthObject alloc] init];
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    self.requestHistory = [[NSArray alloc] init];
    self.failedRequestHistory = [[NSArray alloc] init];
    self.sessionID = @"";
    
    return self;
}

-(NSDictionary *)constructParameterWithKey:(NSString *)key AndValue:(id)value addToDictionary:(NSDictionary *)dict
{
    if (!key || !value)  return nil;
    
    NSMutableDictionary* tmpParams = [[NSMutableDictionary alloc] init];
    
    if (dict && dict.count > 0){
        
        NSArray* keys = [dict allKeys];
        
        for(int count = 0; count < dict.count; count++){
            NSString* key = keys[count];
            id obj = [dict objectForKey:key];
            
            [tmpParams setObject:obj forKey:key];
        }
        
    }
    
    [tmpParams setObject:value forKey:key];
    
    return tmpParams.copy;
}

-(void)appendToCurrentSearchFilter:(NSDictionary *)dictionary
{
    if(!dictionary || dictionary.count < 1) return;
    
    NSMutableDictionary* mutableFilter = [[self getCurrentSearchFilter] mutableCopy];
    
    [mutableFilter addEntriesFromDictionary:dictionary];
    
    NSDictionary* currentFilter = mutableFilter.copy;
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:currentFilter forKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
}

-(NSDictionary *)getCurrentSearchFilter
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* criteria = [userDefault objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    return criteria;
}

-(void)clearCurrentSearchFilter
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault removeObjectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    [userDefault synchronize];
    
    NSLog(@"Cleared Current Search Filter");
}

-(void)setSessionID:(NSString *)sessionID addCompletetion:(generalBlockResponse)completionHandler
{
    if (!sessionID) completionHandler(FALSE);
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionID forKey:KEY_SESSION_ID];
    completionHandler(TRUE);
}

-(NSString *)getSessionID
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    id object = [userDefault objectForKey:KEY_SESSION_ID];
    if (!object) return nil;
    
    NSString* sessionID = object;
    return sessionID;
}

-(void)clearSession
{
    self.sessionID = @"";
}

-(void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

-(NSArray *)removeDuplicateFromArray:(NSArray *)list Unordered:(BOOL)ordered
{
    if(!list) return nil;
    
    NSArray* newList;
    
    if (ordered == FALSE) newList = [[NSSet setWithArray:list] allObjects];
    else{
        NSOrderedSet* set = [NSOrderedSet orderedSetWithArray:list];
        newList = [set array];
    }
    
    return newList;
}

-(void)addToRequestHistory:(id)request
{
    NSMutableArray* historyCopy = self.requestHistory.mutableCopy;
    
    [historyCopy addObject:request];
    
    self.requestHistory = historyCopy.copy;
    
    NSLog(@"request saved");
}

-(NSString *)constructURLPath:(NSString *)hostName API:(NSString *)api Query:(NSDictionary *)query AdditionalParameters:(NSDictionary *)params HTTPMethod:(NSString *)method PortNumber:(NSInteger)port SSL:(BOOL)useSSL
{
    NSMutableString* urlString;
    
    if (!hostName) {
        urlString = [NSMutableString stringWithFormat:@"%@", self.baseURLString];
    }
    else{
        urlString = [NSMutableString stringWithFormat:@"%@://%@", useSSL ? @"https" : @"http", hostName];
    }
    
    if(port != 0)
        [urlString appendFormat:@":%ld", (long)port];
    
    if(api.length > 0 && [api characterAtIndex:0] == '/') // if user passes /, don't prefix a slash
        [urlString appendFormat:@"%@", api];
    else [urlString appendFormat:@"/"];
    
    
    NSString* finalURL = [NSString stringWithString:urlString];
    
    return finalURL;
}

-(void)logout
{
    
}

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler
{
    
}

-(void)logFailedRequest:(id)failedRequest
{
    NSMutableArray* historyCopy = self.failedRequestHistory.mutableCopy;
    
    [historyCopy addObject:failedRequest];
    
    self.failedRequestHistory = historyCopy.copy;
    
    NSLog(@"failed request logged");
}

@end
