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
-(void) surroundingZipcodesReturned:(NSArray*) zipcodes andCriteria:(NSDictionary*) searchCriteria;
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

//@property (nonatomic) int updateState;

-(id) init;

-(id) initWithEngineHostName:(NSString*)hostName;

-(void) startUpdates;

-(void) startUpdates:(id) currentVC;

-(BOOL) shouldStartUpdatesBasedOnAuthorization: (CLAuthorizationStatus) authorizationStatus;

-(void) stopUpdates;

-(void) populateStatesList;

-(BOOL) isCurrentZipcodeExists;

-(BOOL) searchZipcode: (NSString *) aZipcode;

-(BOOL) isValidZipcode: (NSString *) aZipcode;

-(void) attemptToAddCurrentLocation:(CityDataObject*) aCity addCompletionHandler:(addLocationResponse)completionHandler;

-(NSString*) retrieveCurrentLocation;

-(void) fetchLocationInformation:(NSArray*) locations;

-(void) fetchCoordinates:(Deal*) deal addCompletionHandler:(generalCompletionHandler)completionHandler;

-(BOOL) validateZipcodeInput:(NSString*)newInput withOldString: (NSString*)oldString;

-(void) applicaitonHasLaunchedOnced;

-(BOOL) hasLocationsRecorded;

-(BOOL) hasMetLocationTimeThreshold;

-(CLLocation*) getCurrentLocation;

-(NSString*) getCurrentZipcode;

-(void) fetchSurroundingZipcodesWithPostalCode:(NSString*)postalCode andObjects:(NSDictionary*) usersObjects;

//-(void) fetchSurroundingZipcodesWithPostalCode:(NSString*)postalCode andObjects:(NSDictionary*)usersObject addCompletionHandler:(fetchPostalCompletionHandler)completionHandler;

-(void) fetchSurroundingZipcodesWithCurrentLocation:(CLLocation*)currentLocation andObjects:(NSDictionary*) usersObjects;

-(void) fetchSurroundingZipcodesWithCurrentLocation;

-(void) reset;

@end
