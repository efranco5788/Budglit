//
//  TwitterRequestObject.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/13/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "TwitterRequestObject.h"

@implementation TwitterRequestObject
{
    bool includeCallback;
}

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.urlPath = [[NSString alloc] init];
        self.initialRequestAuthorizationHeader = [[NSDictionary alloc] init];
        self.finalRequestAuthorizationHeader = [[NSDictionary alloc] init];
        self.requestSignatureBase = [[NSString alloc] init];
        self.requestSigningKey = [[NSString alloc] init];
        self.requestEncryptedSignature = [[NSString alloc] init];
        self.httpMethod = [[NSString alloc] init];
        self.encodedCallbackURL = [[NSString alloc] init];
        self.query = [[NSDictionary alloc] init];
        self.additonalParams = [[NSDictionary alloc] init];
        includeCallback = NO;
    }
    
    return self;
}

-(void)includeCallback:(BOOL)include
{
    includeCallback = include;
}

-(BOOL)shouldIncludeCallback
{
    return includeCallback;
}

@end
