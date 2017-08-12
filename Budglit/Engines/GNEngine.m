//
//  GNEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "GNEngine.h"

#define PARAM_USERNAME @"efranco5788"
#define KEY_FOR_USERNAME @"username"
//#define POSTAL_CODE_NEARBY_SEARCH_URL @"http://api.geonames.org/findNearbyPostalCodesJSON"
//#define POSTAL_CODE_NEARBY_SEARCH_URL @"findNearbyPostalCodesJSON"
#define POSTAL_CODE_NEARBY_SEARCH_URL @"zipcode"

@implementation GNEngine

-(id)init
{
    return [self initWithHostName:nil];
}

-(id)initWithHostName:(NSString *)hostName
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)GNFetchNeabyPostalCodesWithCoordinates:(NSDictionary *)parameters
{    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.sessionManager GET:POSTAL_CODE_NEARBY_SEARCH_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if(responseObject)
        {
            [self.delegate nearbyPostalCodesFound:responseObject];
        }
        else
        {
            NSError* error = [[NSError alloc] init];
            
            [self.delegate nearbyPostalCodesFailedWithError:error];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
    }];
    
}

-(void)GNFetchNeabyPostalCodesWithPostalCode:(NSDictionary *)parameters
{
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.sessionManager GET:POSTAL_CODE_NEARBY_SEARCH_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSLog(@"%@", responseObject);
        
        if (responseObject) {
            [self.delegate nearbyPostalCodesFound:responseObject];
        }
        else{
            [self.delegate nearbyPostalCodesFailedWithError:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.delegate nearbyPostalCodesFailedWithError:error];
        
        [self logFailedRequest:task];
        
    }];
    
}

@end
