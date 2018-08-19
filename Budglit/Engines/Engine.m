//
//  Engine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//
#import "Engine.h"

#define DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.sssZ"
#define KEY_SESSION_COOKIES @"sessionCookies"

@interface Engine()

@property (nonatomic, strong) NSArray* requestHistory;
@property (nonatomic, strong) NSArray* failedRequestHistory;

@end

@implementation Engine
@synthesize baseURLString = _baseURLString;

+(NSDateFormatter *)constructDateFormatterForTimezone:(NSString *)userTimezone
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timezone;
    
    if(!userTimezone) timezone = [NSTimeZone localTimeZone];
    else timezone = [NSTimeZone timeZoneWithName:userTimezone];
    
    NSLog(@"%@", timezone);
    
    formatter.dateFormat = DATE_FORMAT;
    
    formatter.timeZone = timezone;
    
    if(!formatter) return nil;
    
    return formatter;
}

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
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [configuration setHTTPShouldSetCookies:YES];
    [configuration setHTTPCookieStorage:[NSHTTPCookieStorage sharedHTTPCookieStorage]];
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
    
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

-(id)getSavedCookieForDomain:(NSString*)domain
{
    if(!domain) return nil;
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    if(cookies.count < 1) return nil;
    
    for (NSHTTPCookie* cookie in cookies) {
        NSString* cookieDomain = cookie.domain;
        if([cookieDomain isEqualToString:domain]) return cookie;
    }
    
    return nil;
}

-(void)cookieHasExpired:(NSHTTPCookie *)cookie addCompletion:(generalBlockResponse)completionHandler
{
    NSDate* date = cookie.expiresDate;
    
    NSLog(@"%@", cookie.expiresDate);
    
    NSDate* localDate = [self convertUTCDateToLocal:date];
    
    NSLog(@"%@", localDate);
    
    if([localDate timeIntervalSinceNow] < 0.0) completionHandler(YES);
    else completionHandler(NO);
}

-(void)removeCookie:(NSHTTPCookie *)cookie addCompletion:(generalBlockResponse)completionHandler
{
    if(!cookie) completionHandler(NO);
    
    NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray* cookies = [storage cookies];
    
    for (int i = 0; i < cookies.count; i++) {
        
        if([[cookies objectAtIndex:i] isEqual:cookie]){
            
            [storage deleteCookie:[cookies objectAtIndex:i]];
            
            completionHandler(YES);
        }
        
    }
    
    completionHandler(NO);
}

- (NSDate*)convertLocalToUTCDate:(NSDate*)localDate
{
    if(!localDate) return nil;
    
    NSDateFormatter *dateFormatter = [Engine constructDateFormatterForTimezone:@"UTC"];
    
    NSString* stringDate = [dateFormatter stringFromDate:localDate];
    
    if(!stringDate) return nil;
    
    return [dateFormatter dateFromString:stringDate];
    
}

-(NSDate*)convertUTCDateToLocal:(NSDate*)utcDate
{
    if(!utcDate) return nil;
    
    NSDateFormatter *dateFormatter = [Engine constructDateFormatterForTimezone:nil];
    
    NSString* localDateString = [dateFormatter stringFromDate:utcDate];
    
    if(!localDateString) return nil;
    
    return [dateFormatter dateFromString:localDateString];
}

-(NSString*)convertUTCDateToLocalString:(NSString*)utcDate
{
    if(!utcDate) return nil;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = DATE_FORMAT;
    
    NSDate* date = [formatter dateFromString:utcDate];
    
    if(!date) return nil;
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    
    NSISO8601DateFormatOptions options = NSISO8601DateFormatWithInternetDateTime | NSISO8601DateFormatWithDashSeparatorInDate | NSISO8601DateFormatWithColonSeparatorInTime | NSISO8601DateFormatWithTimeZone;
    
    return [NSISO8601DateFormatter stringFromDate:date timeZone:timeZone formatOptions:options];
}

-(NSString *)convertLocalToUTCDateString:(NSString *)localDate
{
    if(!localDate) return nil;
    
    NSDateFormatter *dateFormatter = [Engine constructDateFormatterForTimezone:@"UTC"];
    
    NSDate* date = [dateFormatter dateFromString:localDate];
    
    if(!date) return nil;
    
    return [dateFormatter stringFromDate:date];
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
