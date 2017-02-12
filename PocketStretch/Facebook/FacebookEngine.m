//
//  FacebookEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/29/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "FacebookEngine.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>

#define FACEBOOK_HOST_NAME @"https://graph.facebook.com"
#define FB_NAME @"name"
#define FB_LOCATION @"user_location"


@implementation FacebookEngine

-(void)getUserLocation
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me"
                                  parameters:@{ @"fields": @"id,location,name",}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        NSLog(@"%@", result);
        
        // Insert your code here
    }];
}

@end
