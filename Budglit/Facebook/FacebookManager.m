//
//  FacebookManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/29/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "FacebookManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FacebookEngine.h"

@implementation FacebookManager

-(instancetype)init
{
    self = [self initWithEngine];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithEngine
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[FacebookEngine alloc] init];
    
    return self;
}

-(BOOL)isLoggedIn
{
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [self.engine getUserLocation];
        
        return YES;
    }
    
    return NO;
}

@end
