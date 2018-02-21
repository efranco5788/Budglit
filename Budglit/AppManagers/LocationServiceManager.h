//
//  LocationServiceManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@class LoadingLocalDealsViewController;
@class CityDataObject;
@class GNEngine;
@class Deal;

typedef void (^addLocationResponse)(BOOL success);
typedef void (^generalCompletionHandler)(BOOL success);
typedef void (^fetchPostalCompletionHandler)(id object);

@protocol LocationManagerDelegate <NSObject>
@optional
-(void) locationDidFinish;
-(void) onlineAttemptFailed;
-(void) offlineAttemptFailed;
-(void) coordinateFetched:(id)deal;
//-(void) surroundingZipcodesReturned:(NSArray*) zipcodes;
@end

@interface LocationSeviceManager : NSObject<CLLocationManagerDelegate, UINavigationControllerDelegate>
{
@private id currentViewController;
@private NSInteger attempts;
@private dispatch_queue_t backgroundQueue;
}

+ (LocationSeviceManager *) sharedLocationServiceManager;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) GNEngine* engine;
@property (nonatomic, assign) id<LocationManagerDelegate> delegate;
@property (nonatomic, copy) NSArray* cities;
@property (nonatomic, strong) CLLocation *currentLocation;

//@property (nonatomic) int updateState;

-(instancetype) init;
-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void) startUpdates;
-(void) startUpdates:(id) currentVC;

-(BOOL) shouldStartUpdatesBasedOnAuthorization: (CLAuthorizationStatus) authorizationStatus;

-(void) stopUpdates;

-(void) populateStatesList;

@property (NS_NONATOMIC_IOSONLY, getter=isCurrentZipcodeExists, readonly) BOOL currentZipcodeExists;

-(BOOL) searchZipcode: (NSString *) aZipcode;

-(BOOL) isValidZipcode: (NSString *) aZipcode;

-(void) attemptToAddCurrentLocation:(CityDataObject*) aCity addCompletionHandler:(addLocationResponse)completionHandler;

-(CityDataObject*) getCurrentLocationCityObject;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *retrieveCurrentLocationString;

-(void) fetchLocationInformation:(NSArray*) locations;

-(void) fetchCoordinates:(Deal*) deal addCompletionHandler:(generalCompletionHandler)completionHandler;

-(BOOL) validateZipcodeInput:(NSString*)newInput withOldString: (NSString*)oldString;

-(void) applicaitonHasLaunchedOnced;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasLocationsRecorded;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasMetLocationTimeThreshold;

@property (NS_NONATOMIC_IOSONLY, getter=getCurrentZipcode, readonly, copy) NSString *currentZipcode;

-(CLLocation *)getCurrentLocation;

-(void) fetchSurroundingZipcodesWithPostalCode:(NSString*)postalCode andObjects:(NSDictionary*) usersObjects addCompletionHandler:(fetchPostalCompletionHandler)completionHandler;

-(void) fetchZipcodesForCity:(CityDataObject*)city andObjects:(NSDictionary*)usersObject addCompletionHandler:(fetchPostalCompletionHandler)completionHandler;

-(void) fetchSurroundingZipcodesWithCurrentLocation:(CLLocation*)currentLocation andObjects:(NSDictionary*) usersObjects addCompletionHandler:(fetchPostalCompletionHandler)completionHandler;

-(void) fetchSurroundingZipcodesWithCurrentLocation;

-(CLLocation*)managerCreateLocationFromStringLongtitude:(NSString *)lng andLatitude:(NSString *)lat;

-(CLLocation*)managerCreateLocationWithLongtitude:(CLLocationDegrees)longtitude andLatitude:(CLLocationDegrees)latitude;

-(void) reset;

@end
