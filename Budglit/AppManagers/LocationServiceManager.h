//
//  LocationServiceManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Manager.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@class LoadingLocalDealsViewController;
@class CityDataObject;
@class LocationEngine;
@class Deal;

@protocol LocationManagerDelegate <NSObject>
@optional
-(void) locationDidFinish;
-(void) onlineAttemptFailed;
-(void) offlineAttemptFailed;
-(void) coordinateFetched:(id)deal;
//-(void) surroundingZipcodesReturned:(NSArray*) zipcodes;
@end

@interface LocationSeviceManager : Manager <CLLocationManagerDelegate, UINavigationControllerDelegate>
{
@private NSInteger attempts;
@private dispatch_queue_t backgroundQueue;
}

+ (id) sharedLocationServiceManager;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) LocationEngine* engine;
@property (nonatomic, assign) id<LocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocation *currentLocation;

//@property (nonatomic) int updateState;

-(instancetype) init;

-(void) startUpdates;

-(BOOL) shouldStartUpdatesBasedOnAuthorization: (CLAuthorizationStatus) authorizationStatus;

-(void) stopUpdates;

-(NSString*)findStateNameFor:(NSString*)stateAbbr;

@property (NS_NONATOMIC_IOSONLY, getter=isCurrentZipcodeExists, readonly) BOOL currentZipcodeExists;

-(void) attemptToAddCurrentLocation:(CityDataObject*) aCity addCompletionHandler:(addLocationResponse)completionHandler;

-(CityDataObject*) getCurrentLocationCityObject;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *retrieveCurrentLocationString;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasLocationsRecorded;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasMetLocationTimeThreshold;

@property (NS_NONATOMIC_IOSONLY, getter=getCurrentZipcode, readonly, copy) NSString *currentZipcode;

-(void) fetchLocationInformation:(NSArray*) locations;

-(BOOL) validateZipcodeInput:(NSString*)newInput withOldString: (NSString*)oldString;

-(void) applicaitonHasLaunchedOnced;

-(CLLocation*)getCurrentLocation;

-(CLLocationDistance)managerDistanceMetersFromLocation:(CLLocation*)locationA toLocation:(CLLocation*)locationB;

-(void)setDistanceConversionType:(NSInteger)type;

-(double)managerConvertDistance:(double)meters;

-(NSInteger)managerGetShortestDistanceFromDeals:(NSArray*)deals;

-(NSInteger)managerGetLongestDistanceFromDeals:(NSArray*)deals;

-(CLLocation*)managerCreateLocationFromStringLongtitude:(NSString *)lng andLatitude:(NSString *)lat;

-(CLLocation*)managerCreateLocationWithLongtitude:(CLLocationDegrees)longtitude andLatitude:(CLLocationDegrees)latitude;

-(CLLocation*)managerConvertAddressToLocation:(NSDictionary*)dict;

-(void) reset;

@end
