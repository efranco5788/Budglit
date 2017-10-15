//
//  Engine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthObject.h"

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

-(void)setSessionID:(NSString *)sessionID addCompletetion:(generalBlockResponse)completionHandler;

-(NSString*)extractSessionIDFromHeaders:(NSDictionary*)headers;

-(NSString*)getSessionID;

-(void) clearSession;

-(void)logout;

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler;

-(NSString*) constructURLPath:(NSString*)hostName API:(NSString*)api Query:(NSDictionary*)query AdditionalParameters:(NSDictionary*)params HTTPMethod:(NSString*)method PortNumber:(NSInteger)port SSL:(BOOL)useSSL;

@end
