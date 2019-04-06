//
//  LocationEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "LocationEngine.h"
#import "AppDelegate.h"
#import "Deal.h"

#define PARAM_USERNAME @"efranco5788"
#define KEY_FOR_USERNAME @"username"
#define POSTAL_CODE_NEARBY_SEARCH_URL @"api/zipcode"
#define MINIMUM_DISTANCE_LBL_DEFAULT @"Under 1 mile"
#define MAXIMUM_DISTANCE_LBL_DEFAULT @"0"
//#define MILE_CONVERSION @"miles"
//#define KILOMETER_CONVERSION @"kilometers"
#define MakeLocation(lat,lon) [[CLLocation alloc]initWithLatitude: lat longitude: lon]

@interface LocationEngine () <EngineDelegate>

@end

@implementation LocationEngine

typedef NS_ENUM(NSInteger, DISTANCE_CONERSION){
    MILE_CONVERSION = 0,
    KILOMETER_CONVERSION = 1
};

DISTANCE_CONERSION conversionType;

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
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    conversionType = MILE_CONVERSION;
    
    [self setDelegate:self];
    
    return self;
}

-(void)setDistanceConversionType:(NSInteger)type
{
    switch (type) {
        case 0:
            conversionType = MILE_CONVERSION;
            break;
        case 1:
            conversionType = KILOMETER_CONVERSION;
            break;
        default:
            break;
    }
}

-(NSDictionary *)loadStates
{
    NSBundle* main = [NSBundle mainBundle];
    
    NSString* stateListPath = [main pathForResource:@"States" ofType:@"plist"];
    
    NSDictionary* stateDictionary = [[NSDictionary alloc] initWithContentsOfFile:stateListPath];
    
    return stateDictionary;
}

-(double)convertLocationDistanceMeters:(double)meters
{
    if (conversionType == MILE_CONVERSION) {
        return (meters / 1609.344);
    }
    else return (meters / 1000.0);
}

-(NSInteger)findShortestDistance:(NSArray *)deals
{

    int minDistance = 0;
    
    for (Deal* deal in deals) {

        if(deal.annotation){
            
            CLLocationDistance distance = [deal getDistanceFromUser];
            
            if (distance < minDistance) minDistance = floor(distance);
            
        }
        
    }
    
    return minDistance;
    
}

-(NSInteger)findLongestDistance:(NSArray *)deals
{
    int maxDistance = 0;
    
    for (Deal* deal in deals) {

        
        if(deal.annotation){
            
            CLLocationDistance distance = [deal getDistanceFromUser];
            
             if (maxDistance < distance) maxDistance = ceil(distance);
            
        }
        
        
    }
    
    return maxDistance;
}

-(void)GNFetchPostalCodesForCity:(NSDictionary *)parameters addCompletionHandler:(blockResponse)completionHandler
{
    
    [self getRequestToPath:POSTAL_CODE_NEARBY_SEARCH_URL parameters:parameters addCompletion:^(id responseObject) {
        
        if(responseObject) completionHandler(responseObject);
        else completionHandler(nil);
        
    }];
    
}

-(CLLocation *)convertAddressToLocation:(NSDictionary *)addressInfo
{
    if(!addressInfo) return nil;
    
    NSArray* coords = [addressInfo valueForKey:@"coordinates"];
    NSString* latitude = [coords valueForKey:@"lat"];
    NSString* longtitude = [coords valueForKey:@"lng"];
    //NSLog(@"lng %@ nd lat %@", longtitude, latitude);
    
    CLLocation* evntlocation = [self createLocationFromStringLongtitude:longtitude andLatitude:latitude];

    if(!evntlocation) return nil;
    
    return evntlocation;
}

-(CLLocationDistance)getDistanceBetweenLocations:(NSArray *)locations
{
    if(!locations || locations.count < 1) return -1;
    
    CLLocation* locationA = [locations firstObject];
    
    CLLocation* locationB = [locations lastObject];
    
    CLLocationDistance distance = [locationA distanceFromLocation:locationB];
    
    return distance;
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
