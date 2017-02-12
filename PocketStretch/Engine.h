//
//  Engine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthObject.h"

@interface Engine : NSObject

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;

@property (strong, nonatomic) OAuthObject* OAuth;

//@property (nonatomic, strong) AFHTTPRequestOperationManager* requestManager;

@property (readonly) NSString* baseURLString;

-(id)init;

-(id)initWithHostName:(NSString*)hostName;

-(void) addToRequestHistory:(id)request;

-(void) logFailedRequest:(id)failedRequest;

-(NSString*) constructURLPath:(NSString*)hostName API:(NSString*)api Query:(NSDictionary*)query AdditionalParameters:(NSDictionary*)params HTTPMethod:(NSString*)method PortNumber:(NSInteger)port SSL:(BOOL)useSSL;

@end
