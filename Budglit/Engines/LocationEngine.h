//
//  LocationEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"
#import <MapKit/MapKit.h>


@interface LocationEngine : Engine

-(instancetype) init;

-(instancetype) initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

-(void)setDistanceConversionType:(NSInteger)type;

-(double)convertLocationDistanceMeters:(double)meters;

-(NSDictionary*)loadStates;

-(CLLocationDistance)getDistanceBetweenLocations:(NSArray*)locations;

-(CLLocation*)createLocationFromStringLongtitude:(NSString*)lng andLatitude:(NSString*)lat;

-(NSInteger)findShortestDistance:(NSArray*)deals;

-(NSInteger)findLongestDistance:(NSArray*)deals;

-(CLLocation*)createLocationWithLongtitude:(CLLocationDegrees)longtitude andLatitude:(CLLocationDegrees)latitude;

-(CLLocation*)convertAddressToLocation:(NSDictionary*)addressInfo;

-(void)GNFetchPostalCodesForCity:(NSDictionary *)parameters addCompletionHandler:(blockResponse)completionHandler;

@end
