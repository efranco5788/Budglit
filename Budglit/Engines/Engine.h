//
//  Engine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthObject.h"
#import "WebSocket.h"

#define KEY_SESSION_ID @"sessionID"

typedef void (^generalBlockResponse)(BOOL success);
typedef void (^blockResponse)(id response);
typedef void (^blockImageResponse)(UIImage* response);
typedef void (^fetchedImageDataResponse)(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request);

@protocol EngineDelegate <NSObject>
@optional
-(void) requestFailedWithError:(NSDictionary*)info;
@end

@interface Engine : NSObject

@property (nonatomic, strong) id <EngineDelegate> delegate;
@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong) OAuthObject* OAuth;
@property (nonatomic, strong) WebSocket* socket;
@property (readonly) NSString* baseURLString;
@property (nonatomic, strong) NSString* sessionID;


+(NSDateFormatter*)constructDateFormatterForTimezone:(NSString*)userTimezone;

-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)constructWebSocket:(NSString*)token addCompletion:(blockResponse)completionHandler;

-(void)headRequestToPath:(NSString*)path parameters:(id)params addCompletion:(blockResponse)completionHandler;

-(void)getRequestToPath:(NSString*)path parameters:(id)params addCompletion:(blockResponse)completionHandler;

-(void)postRequestToPath:(NSString*)path parameters:(id)params addCompletion:(blockResponse)completionHandler;

-(void)addToRequestHistory:(id)request;

-(void)logFailedRequest:(id)failedRequest;

-(NSDictionary*)constructParameterWithKey:(NSString*)key AndValue:(id)value addToDictionary:(NSDictionary*)dict;

-(NSString*)convertUTCDateToLocalString:(NSString*)utcDate;

-(NSString*)convertLocalToUTCDateString:(NSString*)localDate;

-(NSDate*)convertUTCDateToLocal:(NSDate*)utcDate;

-(NSDate*)convertLocalToUTCDate:(NSDate*)localDate;

-(void)appendToCurrentSearchFilter:(NSDictionary*)dictionary;

-(NSDictionary*)getCurrentSearchFilter;

-(void)clearCurrentSearchFilter;

-(id)getSavedCookieForDomain:(NSString*)domain;

-(void)cookieHasExpired:(NSHTTPCookie*)cookie addCompletion:(generalBlockResponse)completionHandler;

-(void)removeCookie:(NSHTTPCookie*)cookie addCompletion:(generalBlockResponse)completionHandler;

-(NSArray*)removeDuplicateFromArray:(NSArray*)list Unordered:(BOOL)ordered;

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler;

-(NSString*) constructURLPath:(NSString*)hostName API:(NSString*)api Query:(NSDictionary*)query AdditionalParameters:(NSDictionary*)params HTTPMethod:(NSString*)method PortNumber:(NSInteger)port SSL:(BOOL)useSSL;

@end
