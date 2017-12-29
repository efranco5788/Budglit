//
//  Engine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthObject.h"

#define KEY_SESSION_ID @"sessionID"

typedef void (^generalBlockResponse)(BOOL success);

@interface Engine : NSObject

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong) OAuthObject* OAuth;
@property (readonly) NSString* baseURLString;
@property (nonatomic, strong) NSString* sessionID;

-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void) addToRequestHistory:(id)request;

-(void) logFailedRequest:(id)failedRequest;

-(NSDictionary*)constructParameterWithKey:(NSString*)key AndValue:(id)value addToDictionary:(NSDictionary*)dict;

-(void)setSessionID:(NSString *)sessionID addCompletetion:(generalBlockResponse)completionHandler;

-(NSString*)extractSessionIDFromHeaders:(NSDictionary*)headers;

-(void)appendToCurrentSearchFilter:(NSDictionary*)dictionary;

-(NSDictionary*)getCurrentSearchFilter;

-(void)clearCurrentSearchFilter;

-(NSString*)getSessionID;

-(void)clearSession;

-(void)saveCookiesFromResponse:(NSHTTPURLResponse*) response;

-(id)getSavedCookie;

-(void)loadCookies;

-(NSArray*)removeDuplicateFromArray:(NSArray*)list Unordered:(BOOL)ordered;

-(void)logout;

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler;

-(NSString*) constructURLPath:(NSString*)hostName API:(NSString*)api Query:(NSDictionary*)query AdditionalParameters:(NSDictionary*)params HTTPMethod:(NSString*)method PortNumber:(NSInteger)port SSL:(BOOL)useSSL;

@end
