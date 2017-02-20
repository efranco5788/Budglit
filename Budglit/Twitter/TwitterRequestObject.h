//
//  TwitterRequestObject.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/13/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterRequestObject : NSObject

@property (nonatomic, strong) NSString* urlPath;
@property (nonatomic, strong) NSDictionary* initialRequestAuthorizationHeader;
@property (nonatomic, strong) NSDictionary* finalRequestAuthorizationHeader;
@property (nonatomic, strong) NSDictionary* query;
@property (nonatomic, strong) NSString* requestSignatureBase;
@property (nonatomic, strong) NSString* requestSigningKey;
@property (nonatomic, strong) NSString* requestEncryptedSignature;
@property (nonatomic, strong) NSString* httpMethod;
@property (nonatomic, strong) NSString* encodedCallbackURL;
@property (nonatomic, strong) NSDictionary* additonalParams;

-(instancetype) init;

-(void) includeCallback:(BOOL) include;

-(BOOL) shouldIncludeCallback;

@end
