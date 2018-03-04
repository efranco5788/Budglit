//
//  LocationEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"
#import <MapKit/MapKit.h>

typedef void (^dataResponseBlockResponse)(id response);

@protocol LocationEngineDelegate <NSObject>
@optional
-(void) zipcodeCoordinatesFound:(NSDictionary*)coordinates;
-(void) zipcodeCoordinatesFailedWithError:(NSError*)error;
-(void) nearbyPostalCodesFound:(NSDictionary*) postalCodes;
-(void) nearbyPostalCodesFailedWithError:(NSError*) error;
@end

@interface LocationEngine : Engine

@property (nonatomic, strong) id <LocationEngineDelegate> delegate;

-(instancetype) init;

-(instancetype) initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

-(CLLocation*)createLocationFromStringLongtitude:(NSString*)lng andLatitude:(NSString*)lat;

-(CLLocation*)createLocationWithLongtitude:(CLLocationDegrees)longtitude andLatitude:(CLLocationDegrees)latitude;

-(void)GNFetchPostalCodesForCity:(NSDictionary *)parameters addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)GNFetchNeabyPostalCodesWithCoordinates:(NSDictionary *)parameters addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)GNFetchNeabyPostalCodesWithPostalCode:(NSDictionary *)parameters addCompletionHandler:(dataResponseBlockResponse)completionHandler;
@end
