//
//  Engine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

@interface Engine()

@property (nonatomic, strong) NSArray* requestHistory;

@property (nonatomic, strong) NSArray* failedRequestHistory;

@end

@implementation Engine
@synthesize baseURLString = _baseURLString;

-(id) init
{
    return [self initWithHostName:nil];
}

-(id) initWithHostName:(NSString*)hostName
{
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _baseURLString = hostName;
    
    NSURL* baseURL = [NSURL URLWithString:_baseURLString];
    
    //self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    self.OAuth = [[OAuthObject alloc] init];
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    self.requestHistory = [[NSArray alloc] init];
    
    self.failedRequestHistory = [[NSArray alloc] init];
    
    return self;
}

-(void)addToRequestHistory:(id)request
{
    NSMutableArray* historyCopy = self.requestHistory.mutableCopy;
    
    [historyCopy addObject:request];
    
    self.requestHistory = historyCopy.copy;
    
    NSLog(@"request saved");
}

-(void)logFailedRequest:(id)failedRequest
{
    NSMutableArray* historyCopy = self.failedRequestHistory.mutableCopy;
    
    [historyCopy addObject:failedRequest];
    
    self.failedRequestHistory = historyCopy.copy;
    
    NSLog(@"failed request logged");
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


@end
