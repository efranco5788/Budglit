//
//  LocationServiceManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "LocationServiceManager.h"
#import "LoadingLocalDealsViewController.h"
#import <dispatch/dispatch.h>
#import "GNEngine.h"
#import "CityDataObject.h"
#import "Deal.h"
#import "AppDelegate.h"
#import "PostalCode.h"

#define HAS_LAUNCHED_ONCE @"HasLaunchedOnce"
#define ADDRESS @"address"
#define CITY @"city"
#define STATE @"state"
#define STATE_NAME @"Name"
#define ZIPCODE @"zipcode"
#define ABBREVIATION @"Abbreviation"
#define DISTANCE_FILTER @"distance_filter"
#define LOCATION @"recorded_location"
#define RECORDED_TIME @"recorded_time"
#define ZIPCODE_LENGTH 5
#define CURRENT_LOCATION_AGE_THRESHOLD 5
#define LOCATION_TIME_THRESHOLD 600
#define DISTANCE_FILTER_THRESHOLD 1609.34
#define KM_PER_MILE 1.60934
#define KEY_FOR_ALL_POSTAL_CODES @"postalCodes"
#define KEY_FOR_POSTAL_CODE @"postalCode"
#define KEY_FOR_LATITUDE @"lat"
#define KEY_FOR_LONGTITUDE @"lng"
#define KEY_FOR_RADIUS @"radius"
#define KEY_FOR_ROWS @"maxRows"
#define KEY_FOR_COUNTRY @"country"
#define KEY_FOR_LOCAL_COUNTRY @"localCountry"
#define KEY_FOR_USERNAME @"username"
#define MAX_ROWS @"20"
#define DEFAULT_RADIUS @"1"
#define DEFAULT_ROWS @"5"
#define GN_API_PARAM_USERNAME @"efranco5788"

static LocationSeviceManager* sharedManager;

@interface LocationSeviceManager()<GNEngineDelegate>
@property NSArray* locationHistory;

@end

@implementation LocationSeviceManager
@synthesize cities;


+ (LocationSeviceManager*) sharedLocationServiceManager
{
    if (sharedManager == nil) {
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            sharedManager = [[super alloc] init];
        });
    }
    return sharedManager;
}

- (id)init
{
    return [self initWithEngineHostName:nil];
}

-(id)initWithEngineHostName:(NSString *)hostName
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[GNEngine alloc] initWithHostName:hostName];
    
    [self.engine setDelegate:self];
    
    self.locationHistory = [[NSArray alloc] init];
    
    [self populateStatesList];
 
    
    return self;
}


#pragma mark -
#pragma mark - Zipcode Services
-(void) populateStatesList
{
    NSBundle* main = [NSBundle mainBundle];
    
    NSString* stateListPath = [main pathForResource:@"States" ofType:@"plist"];
    
    NSMutableArray* cityList = [[NSMutableArray alloc] init];
    
    NSDictionary* dictionary = [[NSDictionary alloc] initWithContentsOfFile:stateListPath];
    
    NSArray* allStates = dictionary.allKeys;
    
    for (NSString* state in allStates) {
        
        NSMutableDictionary* cityPostal = [[dictionary objectForKey:state] mutableCopy];
        
        NSString* stateAbbr = [[NSString alloc] initWithString:[cityPostal valueForKey:ABBREVIATION]];
        
        CityDataObject* city = nil;
        
        for (NSString* postal in cityPostal) {
            
            if (![postal isEqualToString:ABBREVIATION]) {
                
                NSString* cityValue = [cityPostal valueForKey:postal];
                
                city = [[CityDataObject alloc] initWithCity:cityValue State:state stateAbbr:stateAbbr andPostal:postal];
                
                [cityList addObject:city];
            }
            
        }
        
    }
    
    [self setCities:cityList.copy];
    
    NSLog(@"Offline Location Database loaded");
}


-(BOOL)isCurrentZipcodeExists
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults objectForKey:ZIPCODE] isEqualToString:@"0"])
    {
        return NO;
    }
    else return YES;
}

-(BOOL)hasLocationsRecorded
{
    if (self.locationHistory.count < 1) {
        return FALSE;
    }
    else return TRUE;
}

-(void)attemptToAddCurrentLocation:(CityDataObject *)aCity addCompletionHandler:(addLocationResponse)completionHandler
{
    if (self.cities == nil) {
        [self populateStatesList];
    }
    
    if (!aCity) {
        completionHandler(NO);
    }
    else{
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString* zipcode = aCity.postal;
        
        NSString* stateName = aCity.state;
        
        NSString* stateAbbreviation = aCity.stAbbr;
        
        NSString* city = aCity.name;
        
        [defaults setObject:zipcode forKey:ZIPCODE];
        [defaults setObject:stateName forKey:STATE];
        [defaults setObject:stateAbbreviation forKey:ABBREVIATION];
        [defaults setObject:city forKey:CITY];
        
        [defaults synchronize];
        
        NSLog(@"Current Location saved");
        
        completionHandler(YES);
    }
    
}

-(BOOL)searchZipcode: (NSString*) aZipcode
{
    if(self.cities == nil)
    {
        [self populateStatesList];
    }
    
    NSPredicate* postalSearch = [NSPredicate predicateWithFormat:@"postal = %@", aZipcode];
    
    NSArray* postalResults = [self.cities filteredArrayUsingPredicate:postalSearch];
    
    if (postalResults.count <= 0) {
        return NO;
    }
    
    return YES;
}

-(BOOL) isValidZipcode: (NSString*) aZipcode
{
    if(self.cities == nil){
        [self populateStatesList];
    }
    
    NSCharacterSet* numericChars = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* zipcode = [NSCharacterSet characterSetWithCharactersInString:aZipcode];
    
    // Validate that user input has no letters or special characters
    if(![numericChars isSupersetOfSet:zipcode])
    {
        return NO;
    }
    else
    {
        numericChars = nil;
        zipcode = nil;
        
        // Check if user input is 5 digits long
        if ([aZipcode length] < 5 || [aZipcode length] > 5) {
            return NO;
        }
        else
        {
            // Check if Zipcode exists in database
            if (![self searchZipcode:aZipcode]) {
                return NO;
            }
        }
        return YES;
    }
}


#pragma mark -
#pragma mark - Location Services
-(void)startUpdates: (id)currentVC
{
    currentViewController = currentVC;
    [self startUpdates];
}

-(void)startUpdates
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [self.locationManager setDistanceFilter:DISTANCE_FILTER_THRESHOLD];
        self.locationHistory = [[NSArray alloc] init];
        attempts = 0;
    }
    
    [self.locationManager setDelegate:self];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else{
        [self.locationManager startUpdatingLocation];
    }
    
}

-(void)stopUpdates // Stop receiving updates
{
    [self.locationManager stopUpdatingLocation];
    
    self.locationManager.delegate = nil;
    
    attempts = 0;
    
    NSLog(@"Location Services was terminated");
}


#pragma mark -
#pragma mark - Location Services Delegate
//Validate the authorization status of the app
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            NSLog(@"Location Services has started");
            break;
        default:
            [self.delegate onlineAttemptFailed];
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self stopUpdates];
    
    CLLocation* recentLocation = [locations lastObject];
    
    if (recentLocation.horizontalAccuracy < 0) {
        NSLog(@"horizontal accuracy error");
        return;
    }
    
    NSDate* locationDate = recentLocation.timestamp;
    
    NSTimeInterval locationAge = [locationDate timeIntervalSinceNow];
    
    float ageOfLocation = fabs(locationAge);
    
    // Verify location is current
    if (ageOfLocation <= CURRENT_LOCATION_AGE_THRESHOLD)
    {
        NSLog(@"Current Location %f seconds", ageOfLocation);
        
        NSDate* recordedTime = [NSDate date];
        
        NSDictionary* currentLocation = [[NSDictionary alloc] initWithObjectsAndKeys:recentLocation, LOCATION, recordedTime, RECORDED_TIME, nil];
        
        [self recordLocation:currentLocation];
        
        NSLog(@"New Location was found and added");
        [self fetchLocationInformation:nil];
    }
    else
    {
        //NSLog(@"Location is old: %f seconds", fabs(locationAge));
        NSLog(@"Location is old: %f seconds", ageOfLocation);
        [self startUpdates];
    }
    
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    attempts = attempts + 1;
    
    switch (error.code) {
        case kCLErrorLocationUnknown:
            if (attempts <= 3) {
                NSLog(@"Attempt %ld", (long)attempts);
            }
            else
            {
                [self stopUpdates];
                [self.delegate onlineAttemptFailed];
            }
            break;
        case kCLErrorGeocodeCanceled:
            [self stopUpdates];
            break;
        default:
            if (attempts < 0) {
                [self startUpdates];
            }
            else if (attempts > 0 && attempts < 3)
            {
                [NSThread sleepForTimeInterval:2];
                [self startUpdates];
            }
            else
                [self stopUpdates];
            [self.delegate onlineAttemptFailed];
            break;
    }
}

-(BOOL) shouldStartUpdatesBasedOnAuthorization: (CLAuthorizationStatus) authorizationStatus
{
    int status = authorizationStatus;
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}


#pragma mark -
#pragma mark - Current Location
-(NSString*) retrieveCurrentLocation
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* formattedCurrentLocationString = [[NSString alloc] initWithFormat:@"%@, %@", [defaults objectForKey:CITY], [defaults objectForKey:ABBREVIATION]];
    
    return formattedCurrentLocationString;
}

-(void) fetchLocationInformation:(NSArray*)locations
{
    CLGeocoder* coder = [[CLGeocoder alloc] init];
    
    if (locations == nil) {
        
        NSDictionary* tempRecentLocation = [self.locationHistory lastObject];
        
        CLLocation* mostRecentLocation = [tempRecentLocation objectForKey:LOCATION];
        
        [coder reverseGeocodeLocation: mostRecentLocation completionHandler:^(NSArray* placemarks, NSError* error){
            
            if (error) {
                NSLog(@"%@", error.description);
                [self.delegate onlineAttemptFailed];
            }
            else
            {
                CLPlacemark* currentLocation = [placemarks objectAtIndex:0];
                
                NSDictionary* address = [currentLocation addressDictionary];
                
                NSString* cityName = [address valueForKey:@"City"] ;
                
                NSString* state = [address valueForKey:@"State"];
                
                NSString* postal = [currentLocation postalCode];
                
                CityDataObject* city = [[CityDataObject alloc] initWithCity:cityName State:state stateAbbr:state andPostal:postal];
                
                [self attemptToAddCurrentLocation:city addCompletionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                        
                        id hasLaunched = [defaults objectForKey:HAS_LAUNCHED_ONCE];
                        
                        BOOL hasLaunchedOnce = [hasLaunched boolValue];
                        
                        if(hasLaunchedOnce == NO)
                        {
                            [self applicaitonHasLaunchedOnced];
                        }
                        
                        [self.delegate locationDidFinish];
                        
                    }
                    
                }];
                
            }
            
        }];
    }
    else{
        
        for (CLLocation* location in locations) {
            
            [coder reverseGeocodeLocation: location completionHandler:^(NSArray* placemarks, NSError* error){
                
                if (error) {
                    NSLog(@"%@", error.description);
                }
                else
                {
                    CLPlacemark* currentLocation = [placemarks objectAtIndex:0];
                    
                    NSString* recentZipcode = [currentLocation postalCode];
                    
                    NSLog(@"Zipcode: %@", recentZipcode);
                    
                    [self.delegate locationDidFinish];
                }
                
            }];
            
        }
    }
    
}

-(void)fetchCoordinates:(Deal *)deal addCompletionHandler:(generalCompletionHandler)completionHandler
{
    CLGeocoder* coder = [[CLGeocoder alloc] init];
    
    NSString* stringAddress = deal.getAddressString;
    
    [coder geocodeAddressString:stringAddress inRegion:nil completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark* location = [placemarks objectAtIndex:0];
        
        CLLocationCoordinate2D coordinates = location.location.coordinate;
        
        [deal setCoordinates:coordinates];
        
        completionHandler(YES);
        
    }];
    
}

-(BOOL)hasMetLocationTimeThreshold
{
    NSDictionary* currentLocation = [self.locationHistory lastObject];
    
    NSDate* timestamp = [currentLocation objectForKey:RECORDED_TIME];
    
    NSTimeInterval age = [timestamp timeIntervalSinceNow];
    
    if (fabs(age) <= LOCATION_TIME_THRESHOLD) {
        return NO;
    }
    else return YES;
}

-(void)recordLocation:(NSDictionary*)location
{
    NSMutableArray* copyLocationHistory = self.locationHistory.mutableCopy;
    
    [copyLocationHistory addObject:location];
    
    self.locationHistory = copyLocationHistory.copy;
    
    NSLog(@"Location recorded");
}



#pragma mark -
#pragma mark - App Defaults
-(void)applicaitonHasLaunchedOnced
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* launchedOnce = [NSNumber numberWithBool:YES];
    
    [defaults setObject:launchedOnce forKey:HAS_LAUNCHED_ONCE];
    
    [defaults synchronize];
    
    NSLog(@"App has launched once");
}


#pragma mark -
#pragma mark - Zipcode Input Validation
-(BOOL)validateZipcodeInput:(NSString *)newInput withOldString:(NSString *)oldString
{
    
    if ([newInput isEqualToString:@""]) {
        return YES;
    }
    
    if ([oldString length] >= ZIPCODE_LENGTH) {
        return NO;
    }
    else return YES;
}

-(CLLocation *)getCurrentLocation
{
    if (self.locationHistory == 0) {
        return nil;
    }
    else
    {
        CLLocation* currentLocation = [[self.locationHistory lastObject] valueForKey:LOCATION];
        
        return currentLocation;
    }
}

-(NSString*)getCurrentZipcode
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userZipcode = [defaults valueForKey:ZIPCODE];
    
    return userZipcode;
}

-(void)fetchSurroundingZipcodesWithCurrentLocation
{
    CLLocation* currentLocation = [self getCurrentLocation];
    
    NSDictionary* objectDictionary = [NSDictionary dictionary];
    
    [self fetchSurroundingZipcodesWithCurrentLocation:currentLocation andObjects:objectDictionary];
}

-(void)fetchSurroundingZipcodesWithCurrentLocation:(CLLocation*)currentLocation andObjects:(NSDictionary*)usersObjects
{
    
    if (currentLocation == nil) {
        currentLocation = [self getCurrentLocation];
    }

    NSNumber* latitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
    
    NSNumber* longtitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
    
    NSString* lat = [latitude stringValue];
    
    NSString* lng = [longtitude stringValue];
    
    
    
    NSString* miRadius = [usersObjects valueForKey:DISTANCE_FILTER];
    
    if (miRadius == nil) {
        miRadius = DEFAULT_RADIUS;
    }
    
    double milesToKM = ([miRadius doubleValue] * KM_PER_MILE);
    
    NSNumber* totalKM = [NSNumber numberWithDouble:milesToKM];
    
    NSString* kmRadius = [totalKM stringValue];
    
    NSString* rows = MAX_ROWS;
    
    NSString* country = @"US";
    
    NSArray* keys = [NSArray arrayWithObjects:KEY_FOR_LATITUDE, KEY_FOR_LONGTITUDE, KEY_FOR_RADIUS, KEY_FOR_ROWS, KEY_FOR_COUNTRY, KEY_FOR_LOCAL_COUNTRY, KEY_FOR_USERNAME, nil];
    
    NSArray* objects = [NSArray arrayWithObjects:lat, lng, kmRadius, rows, country, @"true", GN_API_PARAM_USERNAME, nil];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    [self.engine GNFetchNeabyPostalCodesWithCoordinates:parameters];
}


-(void)fetchSurroundingZipcodesWithPostalCode:(NSString*)postalCode andObjects:(NSDictionary*)usersObjects
{
    if ([postalCode isEqual:nil]) {
        NSLog(@"Postal code not found!");
        return;
    }
    
    
    NSString* miRadius = [usersObjects valueForKey:DISTANCE_FILTER];
    
    if (miRadius == nil) {
        miRadius = DEFAULT_RADIUS;
    }
    
    double milesToKM = ([miRadius doubleValue] * KM_PER_MILE);
    
    NSNumber* totalKM = [NSNumber numberWithDouble:milesToKM];
    
    NSString* kmRadius = [totalKM stringValue];
    
    NSString* rows = MAX_ROWS;
    
    NSString* country = @"US";
    
    NSString* postal = [KEY_FOR_POSTAL_CODE lowercaseString];
    
    NSArray* keys = [NSArray arrayWithObjects:postal, KEY_FOR_COUNTRY, KEY_FOR_RADIUS, KEY_FOR_ROWS, KEY_FOR_USERNAME, nil];
    
    NSArray* objects = [NSArray arrayWithObjects: postalCode, country, kmRadius, rows, GN_API_PARAM_USERNAME, nil];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    [self.engine GNFetchNeabyPostalCodesWithPostalCode:parameters];
}

/*
-(void)fetchSurroundingZipcodesWithPostalCode:(NSString *)postalCode andObjects:(NSDictionary *)usersObject addCompletionHandler:(fetchPostalCompletionHandler)completionHandler
{
    if ([postalCode isEqual:nil]) {
        NSLog(@"Postal code not found!");
        completionHandler(nil);
    }
    
    
    NSString* miRadius = [usersObject valueForKey:DISTANCE_FILTER];
    
    if (miRadius == nil) {
        miRadius = DEFAULT_RADIUS;
    }
    
    double milesToKM = ([miRadius doubleValue] * KM_PER_MILE);
    
    NSNumber* totalKM = [NSNumber numberWithDouble:milesToKM];
    
    NSString* kmRadius = [totalKM stringValue];
    
    NSString* rows = MAX_ROWS;
    
    NSString* country = @"US";
    
    NSString* postal = [KEY_FOR_POSTAL_CODE lowercaseString];
    
    NSArray* keys = [NSArray arrayWithObjects:postal, KEY_FOR_COUNTRY, KEY_FOR_RADIUS, KEY_FOR_ROWS, KEY_FOR_USERNAME, nil];
    
    NSArray* objects = [NSArray arrayWithObjects: postalCode, country, kmRadius, rows, GN_API_PARAM_USERNAME, nil];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    completionHandler(parameters);
}
*/

#pragma mark -
#pragma mark - Location Engine Delegates
-(void)nearbyPostalCodesFound:(NSDictionary *)postalCodes
{
    __block NSMutableArray* allPostalCodes = [[NSMutableArray alloc] init];
    
    NSArray* fetchedPostalCodes = [postalCodes objectForKey:KEY_FOR_ALL_POSTAL_CODES];
    
    for (NSDictionary* postalCode in fetchedPostalCodes) {
        
        NSString* Pcode = [postalCode valueForKey:KEY_FOR_POSTAL_CODE];
        
        NSString* latitude = [[postalCode valueForKey:KEY_FOR_LATITUDE] stringValue];
        
        NSString* longtitude = [[postalCode valueForKey:KEY_FOR_LONGTITUDE] stringValue];
        
        NSDictionary* coordinates = [[NSDictionary alloc] initWithObjectsAndKeys:longtitude, KEY_FOR_LONGTITUDE, latitude, KEY_FOR_LATITUDE, nil];
        
        PostalCode* newPostalCode = [[PostalCode alloc] initWithPostalCode:Pcode andCoordinates:coordinates];
        
        [allPostalCodes addObject:newPostalCode];
        
    }
    
    NSArray* zipcodes = allPostalCodes.copy;
    
    NSLog(@"%@", zipcodes);
    
    [self.delegate surroundingZipcodesReturned:zipcodes andCriteria:nil];

}


-(void)nearbyPostalCodesFailedWithError:(NSError *)error
{
    
}



#pragma mark -
#pragma mark - User Current Information
-(void)reset
{    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:ZIPCODE];
    [defaults removeObjectForKey:STATE];
    [defaults removeObjectForKey:ABBREVIATION];
    
    [defaults synchronize];
    
    defaults = nil;
    
    NSLog(@"Current Location cleared");
}

@end
