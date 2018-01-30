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
#define MakeLocation(lat,lon) [[CLLocation alloc]initWithLatitude: lat longitude: lon]

@implementation GNEngine

-(instancetype)init
{
    self = [self initWithHostName:nil];
    
    if (!self) return nil;
    
    return self;
}

-(instancetype)initWithHostName:(NSString *)hostName
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)GNFetchNeabyPostalCodesWithCoordinates:(NSDictionary *)parameters addCompletionHandler:(dataResponseBlockResponse)completionHandler
{    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.sessionManager GET:POSTAL_CODE_NEARBY_SEARCH_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if(responseObject)
        {
            completionHandler(responseObject);
        }
        else
        {
            NSError* error = [[NSError alloc] init];
            
            completionHandler(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logFailedRequest:task];
        [self.delegate nearbyPostalCodesFailedWithError:error];
    }];
    
}

-(void)GNFetchNeabyPostalCodesWithPostalCode:(NSDictionary *)parameters addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.sessionManager GET:POSTAL_CODE_NEARBY_SEARCH_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSLog(@"%@", responseObject);
        
        if (responseObject) completionHandler(responseObject);
        else{
            completionHandler(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.delegate nearbyPostalCodesFailedWithError:error];
        [self logFailedRequest:task];
        
    }];
    
}

-(CLLocation *)createLocationFromStringLongtitude:(NSString *)lng andLatitude:(NSString *)lat
{
    CLLocationDegrees longtitude = lng.floatValue;
    
    CLLocationDegrees latitude = lat.floatValue;
    
    CLLocation* locationCreated = [self createLocationWithLongtitude:longtitude andLatitude:latitude];
    
    return locationCreated;
}

-(CLLocation *)createLocationWithLongtitude:(CLLocationDegrees)longtitude andLatitude:(CLLocationDegrees)latitude
{
    CLLocation* locationCreated = MakeLocation(latitude, longtitude);
    
    return locationCreated;
}

@end
