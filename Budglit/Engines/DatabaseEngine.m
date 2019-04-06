//
//  DatabaseEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DatabaseEngine.h"
#import "AppDelegate.h"
#import "UserAccount.h"
#import "CityDataObject.h"
#import "Deal.h"
#import "DealMapAnnotation.h"
#import "ImageData.h"
#import "UIImage+Resizing.h"
#import "UIImageView+AFNetworking.h"
#import "WebSocket.h"

#define SEARCH_DEALS @"search"
#define TEMP_SEARCH_RESULTS @"tempsearch"
#define API_PLACES @"places"
#define HTTP_POST_METHOD @"POST"
#define KEY_EMPTY_VALUES @"emptyValues"
#define KEY_ERROR @"error"
#define KEY_DEALS @"deals"
#define KEY_LIST @"parsedList"
#define DEAL_COUNT @"count"
#define AUTHENTICATED_KEY @"authenticated"
#define AUTHENTICATED_STATUS_KEY @"status"
#define KEY_FORMATTED_ADDRESS @"formatted_address"
#define WEB_SOCKET_CONNECT @"connect"
#define WEB_SOCKET_NEW_DEALS_PULLED @"deals_updated"

#define RESCALE_IMAGE_WIDTH 1024
#define RESCALE_IMAGE_HEIGHT 1024

@interface DatabaseEngine() <WebSocketDelegate>

@end

@implementation DatabaseEngine

-(instancetype) init
{
    self = [self initWithHostName:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype) initWithHostName:(NSString*)hostName
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }

    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    self.sessionManager.requestSerializer.HTTPShouldHandleCookies = YES;
    self.sessionManager.session.configuration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    return self;
}

-(void)constructWebSocket:(NSString *)token addCompletion:(blockResponse)completionHandler
{
    [super constructWebSocket:token addCompletion:completionHandler];
    
    if(!self.socket){
        
        NSURL* baseURL = [NSURL URLWithString:self.baseURLString];
        
        self.socket = [[WebSocket alloc] initWebSocketForDomain:baseURL userToken:token];
        
        self.socket.delegate = self;
        
        NSLog(@"%@", self.socket);
        
    }

    if(!self.socket) completionHandler(nil);
    else completionHandler(self.socket);
    
}

-(void)setSocketEventsAddCompletion:(blockResponse)completionHandler
{
    if(!self.socket) completionHandler(nil);
    else{
        
        [self.socket.socket on:WEB_SOCKET_CONNECT callback:^(NSArray* data, SocketAckEmitter* ack) {
            
            NSLog(@"Socket for Database Engine is now connected");
            
        }];
        
        [self.socket.socket on:WEB_SOCKET_NEW_DEALS_PULLED callback:^(NSArray* data, SocketAckEmitter* ack) {
            
            NSLog(@"New Events have been added.");

            [[NSNotificationCenter defaultCenter] postNotificationName:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
            
        }];
        
        
        [self.socket connectSocket];
        
        completionHandler(self.socket);
        
    }
}


// Constructs the basic default data for the app
-(NSDictionary*)constructDefaultFetchingObjects
{
    NSNumber* launched = @NO;
    
    NSMutableDictionary* currentSearchFilters = [[NSMutableDictionary alloc] init];
    
    NSArray* defaultObjects = @[launched, NSLocalizedString(@"DEFAULT_ZIPCODE", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString (@"DEFAULT_BUDGET", nil), currentSearchFilters];
    
    NSArray* defaultKeys = @[NSLocalizedString(@"HAS_LAUNCHED_ONCE", nil), NSLocalizedString(@"ZIPCODE", nil), NSLocalizedString(@"CITY", nil), NSLocalizedString(@"STATE", nil), NSLocalizedString(@"ABBRVIATION", nil), NSLocalizedString(@"BUDGET", nil), NSLocalizedString(@"CURRENT_SEARCH_FILTERS", nil)];
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjects:defaultObjects forKeys:defaultKeys];
    
    return appDefaults;
}

-(void)saveFetchingObjects:(NSDictionary *)objects addCompletion:(generalBlockResponse)completionHandler
{
    
}

-(BOOL)extractAuthetication:(NSDictionary *)info
{
    NSDictionary* authenStatus = [info valueForKey:AUTHENTICATED_KEY];
    
    BOOL authenticationStauts;
    
    if(!authenStatus) authenticationStauts = FALSE;
    else{
        authenticationStauts = [[authenStatus valueForKey:AUTHENTICATED_STATUS_KEY] boolValue];
    }
    
    return authenticationStauts;
}

-(NSArray*)extractDeals:(NSDictionary *)info
{
    NSArray* deals = [info valueForKey:@"deals"];
    
    return deals;
}

-(NSArray*)filterOutDeals:(NSArray*)deals byBudgetAmount:(double)amount
{
    NSPredicate* budgetPredicate = [NSPredicate predicateWithFormat:@"SELF.budget > %f", amount];
    
    NSArray* filteredArray = [deals filteredArrayUsingPredicate:budgetPredicate];
    
    if(!filteredArray){
        return nil;
    }
    else{
        return filteredArray;
    }
}

-(NSArray*)filterOutDeals:(NSArray*)deals byDistance:(double)distance
{
    NSPredicate* distancePredicate = [NSPredicate predicateWithFormat:@"SELF.getDistanceFromUser > %f", distance];
    
    NSArray* filteredArray = [deals filteredArrayUsingPredicate:distancePredicate];
    
    if(!filteredArray) return nil;
    
    return filteredArray;
}

- (NSInteger)findLowestBudget:(NSArray *)deals
{
    double lowest = 0;
    
    for (Deal* deal in deals) {
        
        double budget = [deal budget];
        
        if (budget < lowest) lowest = budget;
        
    }
    
    return lowest;
}

-(NSInteger)findHighestBudget:(NSArray *)deals
{
    double highest = 0;
    
    for (Deal* deal in deals) {
        
        double budget = [deal budget];
        
        if (budget > highest) highest = budget;
        
    }
    
    return highest;
}

-(NSValue*)calculateCoordinateFrom:(NSValue *)coordinateValue onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres
{
    CLLocationCoordinate2D coordinate;
    [coordinateValue getValue:&coordinate];
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    
    NSValue* newCoordinateValue = [NSValue valueWithBytes:&result objCType:@encode(CLLocationCoordinate2D)];
    
    return newCoordinateValue;
}


-(NSDictionary *)primaryDefaultForSearchFilterAtLocation
{
    NSArray* keys = @[NSLocalizedString(@"DISTANCE_FILTER", nil), NSLocalizedString(@"BUDGET_FILTER", nil), NSLocalizedString(@"DATE_FILTER", nil), NSLocalizedString(@"CITY", nil), NSLocalizedString(@"STATE", nil)];
    
    NSString* distanceCriteria = NSLocalizedString(@"DEFAULT_DISTANCE_FILTER", nil);
    
    NSString* budgetCriteria = NSLocalizedString(@"DEFAULT_BUDGET", nil);
    
    LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
    
    CityDataObject* city = locationManager.getCurrentLocationCityObject;
    
    NSString* cityName = city.name;
    
    NSString* state = city.state;
    
    NSString* currentDate = [self currentDateString];
    
    NSArray* values = @[distanceCriteria, budgetCriteria, currentDate, cityName, state];
    
    NSDictionary* filterCriteria = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    return filterCriteria;
}

-(NSString*)currentDateString
{
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    
    NSISO8601DateFormatOptions options = NSISO8601DateFormatWithInternetDateTime | NSISO8601DateFormatWithDashSeparatorInDate | NSISO8601DateFormatWithColonSeparatorInTime | NSISO8601DateFormatWithTimeZone;

    NSString* currentDate = [NSISO8601DateFormatter stringFromDate:[NSDate date] timeZone:timeZone formatOptions:options];
    
    return currentDate;
}

-(void)sendSearchCriteria:(NSDictionary *)searchCriteria addCompletion:(blockResponse)completionBlock
{
    
    [self postRequestToPath:SEARCH_DEALS parameters:searchCriteria addCompletion:^(id responseObject) {
            
            if (responseObject) {
                
                NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] init];
                
                NSDictionary* authenticatedInfo = [responseObject valueForKey:@"authenticatedInfo"];
                
                NSString* authenticatedValue = [authenticatedInfo valueForKey:@"isAuthenticated"];
                
                if(authenticatedValue != nil){
                    
                    NSInteger isAuthenticated = authenticatedValue.integerValue;
                    
                    NSDictionary* authenticatedInfo;
                    
                    if(isAuthenticated == FALSE){
                        
                        authenticatedInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:AUTHENTICATED_STATUS_KEY];
                        
                        [mutableDict setObject:authenticatedInfo forKey:AUTHENTICATED_KEY];
                        
                        completionBlock(mutableDict.copy);
                        
                    }
                    else{
                        
                        authenticatedInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:AUTHENTICATED_STATUS_KEY];
                        
                        [mutableDict setObject:authenticatedInfo forKey:AUTHENTICATED_KEY];
                        
                        NSDictionary* dealsDict = [responseObject valueForKey:@"dealsInfo"];
                        
                        NSArray* deals = [dealsDict valueForKey:KEY_DEALS];
                        
                        NSInteger total = deals.count;
                        
                        if (total <= 0) {
                            
                            NSString* errorMessage = [responseObject valueForKey:KEY_ERROR];
                            
                            NSLog(@"%@", errorMessage);
                            
                            NSArray* array = [[NSArray alloc] init];
                            
                            [mutableDict setObject:array forKey:@"deals"];
                        }
                        else{
                            
                            [mutableDict setObject:deals forKey:@"deals"];
                            
                        } // end of deals array count else statement
                        
                        completionBlock(mutableDict.copy);
                        
                    } // end of is authenticated status else statement
                    
                } // end of authentication value else statement
                else{
                    
                    NSDictionary* info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:AUTHENTICATED_STATUS_KEY];
                    
                    [mutableDict setObject:info forKey:AUTHENTICATED_KEY];
                    
                    completionBlock(mutableDict.copy);
                    
                }
                
            } // end of if response object is nil statement
            else completionBlock(nil);
        
    }];
 
}

-(void)sendAddressForGeocode:(NSDictionary *)params addCompletionHandler:(blockResponse)completionHandler
{
    if(!params) return;
    
    //self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self postRequestToPath:API_PLACES parameters:params addCompletion:^(id responseObject) {
        
        if(!responseObject) completionHandler(nil);
        else completionHandler(responseObject);
        
    }];
 
}

#warning needs better error handling
-(void)sendAddressesForGeocode:(NSDictionary *)params addCompletionHandler:(blockResponse)completionHandler
{
    if(!params) return;
    
    //self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self postRequestToPath:API_PLACES parameters:params addCompletion:^(id responseObject) {
        
        if(!responseObject) completionHandler(nil);
        else completionHandler(responseObject);

        
    }];

}

-(NSDictionary *)parseGeocodeLocation:(NSDictionary *)locationInfo
{
    if(!locationInfo) return nil;
    
    NSString* formattedAddress = [locationInfo valueForKey:@"formatted_address"];
    
    NSDictionary* geometry = [locationInfo valueForKey:@"geometry"];
    
    NSArray* preferredCoords = [geometry valueForKey:@"viewport"];

    NSDictionary* coordinates = [preferredCoords valueForKey:@"northeast"];
    
    NSString* locationType = [geometry valueForKey:@"location_type"];
    
    NSString* googlePlaceID = [locationInfo valueForKey:@"place_id"];
    
    NSMutableDictionary* mutableParsedInfo = [[NSMutableDictionary alloc] init];
    
    [mutableParsedInfo setValue:formattedAddress forKey:@"formatted_address"];
    [mutableParsedInfo setValue:coordinates forKey:@"coordinates"];
    [mutableParsedInfo setValue:locationType forKey:@"location_type"];
    [mutableParsedInfo setValue:googlePlaceID forKey:@"place_id"];
    
    NSDictionary* parsedInfo = mutableParsedInfo.copy;
    
    NSLog(@"%@", parsedInfo);
    
    if(!parsedInfo) return nil;
    
    return parsedInfo;
}


-(void)downloadImageFromURL:(NSString *)urlString forImageView:(UIImageView *)imageView addCompletionHandler:(fetchedImageDataResponse)completionHandler{
    
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    if(imageView){
        
        NSLog(@"fetching image %@", imageRequest.URL);
        
        [imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            
            NSLog(@"Image fetched %@", response);
            
            completionHandler(image, response, request);
            
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            
            NSLog(@"%@", error);
            
            if (response.statusCode == 404) {
                
                NSLog(@"Image fetched %@", error);
                
                completionHandler(nil, response, request);
                
            }
            
        }];
        
    }
    
}


-(void)getImageFromCacheWithKey:(NSString *)key addCompletionHandler:(blockResponse)completionHandler
{

    if(!key) completionHandler(nil);
    else{
        
        ImageDataCache* cache = [ImageDataCache sharedImageDataCache];
        
        id imgObject = [cache objectForKey:key];
        
        if(!imgObject) completionHandler(nil);
        else completionHandler(imgObject);
    }
    
}

-(void)getImageFromCachePersistenceStorageWithKey:(NSString *)key addCompletionHandler:(blockImageResponse)completionHandler
{
    if(!key) completionHandler(nil);
    else{
        
        ImageDataCache* cache = [ImageDataCache sharedImageDataCache];
        
        [cache getFileFromPersistentStorageCache:key addCompletion:^(UIImage* object) {
            
            if(!object) completionHandler(nil);
            else{
                completionHandler(object);
            }
            
        }];
        
    }
    
}


-(void)cacheImage:(UIImage *)img forKey:(NSString *)key addCompletionHandler:(generalBlockResponse)completionHandler
{
    if(!img || !key) completionHandler(NO);
    else{
        
        ImageDataCache* cache = [ImageDataCache sharedImageDataCache];
        
        [cache setObject:img forKey:key];
        
        completionHandler(YES);
        
    }
}

-(void)saveToCachePersistenceStorageImage:(UIImage *)img forKey:(NSString *)key addCompletionHandler:(generalBlockResponse)completionHandler
{
    if(!img || !key) completionHandler(NO);
    else{
        
        ImageDataCache* cache = [ImageDataCache sharedImageDataCache];
        
        NSData* imgData = UIImagePNGRepresentation(img);
        
        NSArray* stringComponents = [key componentsSeparatedByString:@"/"];
        
        NSString* imgName = [stringComponents lastObject];
        
        [cache saveFileToPersistentStorageCache:imgData withKey:imgName addCompletion:^(BOOL success) {
            
            completionHandler(success);
            
        }];
        
    }

}

#pragma mark -
#pragma mark - Sort Methods
-(void)sortArray:(NSArray *)array byKey:(NSString *)key ascending:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletion:(blockResponse)completionHandler
{
    if(!array) completionHandler(nil);
    
    if(!key) completionHandler(nil);
    
    NSSortDescriptor* descriptor;
    
    if (shouldLocalize) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:shouldAscend selector:@selector(localizedStandardCompare:)];
    }
    else descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:shouldAscend];
    
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[descriptor]];
    
    completionHandler(sortedArray.copy);
}

#pragma mark -
#pragma mark - Map Annotation Methods
/*
-(void)groupAnnotationByCoordinates:(NSMutableArray *)annotations addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    if(annotations == nil || annotations.count <= 0) completionHandler(nil);
    
    NSMutableDictionary* coordinateValuesToAnnotations = [[NSMutableDictionary alloc] init];
    
    for (DealMapAnnotation* pin in annotations) {
        
        CLLocationCoordinate2D coordinates = pin.coordinate;
        NSValue* coordinateValue = [NSValue valueWithBytes:&coordinates objCType:@encode(CLLocationCoordinate2D)];
        
        NSMutableArray* annotationsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            coordinateValuesToAnnotations[coordinateValue] = annotationsAtLocation;
        }
        
        [annotationsAtLocation addObject:pin];
        
    }
    
    completionHandler(coordinateValuesToAnnotations);
}

-(void)attemptToRepositionAnnotations:(id)annotations addCompletionHandler:(generalBlockResponse)completionHandler
{
    if(!annotations) completionHandler(NO);
    
    if ([annotations isKindOfClass:[NSMutableDictionary class]]) {
        
        NSMutableDictionary* annotationsDict = (NSMutableDictionary*) annotations;
        
        NSArray* keys = annotationsDict.allKeys;
        
        double distance = 3 * annotationsDict.count / 2.0;
        double radiansBetweenAnnotations = (M_PI * 2) / annotationsDict.count;
    
        for (id key in keys) {
            NSValue* valueCoordinates = (NSValue*) key;
            
            NSArray* allCoords = [annotationsDict objectForKey:key];
            
            for (int i = 0; i < allCoords.count; i++) {
                double heading = radiansBetweenAnnotations * i;
                
                NSValue* newCoordinateValue = [self calculateCoordinateFrom:valueCoordinates onBearing:heading atDistance:distance];
                
                CLLocationCoordinate2D newCoordinates;
                [newCoordinateValue getValue:&newCoordinates];
                DealMapAnnotation* dealAnnotation = allCoords[i];
                [dealAnnotation setCoordinate:newCoordinates];
                
                NSLog(@"%@", dealAnnotation);
                
                
            } // end of for statement

        } // end of Fast Enumeration For statement
        completionHandler(YES);
    }
    
    completionHandler(NO);
}
*/

-(NSArray*)extractAddressFromDeals:(NSArray *)deals
{
    if(!deals) return nil;
    
    NSMutableArray* tmpAddresses = [[NSMutableArray alloc] initWithCapacity:deals.count];
    
    for (Deal* deal in deals) {
        
        NSString* uniqueID = deal.dealID;
        
        NSString* addressString = deal.addressString;
        
        NSDictionary* address = @{
                                        @"dealID":uniqueID,
                                        @"address":addressString
                                        };
        
        [tmpAddresses addObject:address];
    }
    
    return tmpAddresses.copy;
}

-(NSArray*)createMapAnnotationsForDeals:(NSArray*)deals
{    
    NSMutableArray* mutableAnnotations = [[NSMutableArray alloc] init];
    
    for (Deal* deal in deals) {
        
        DealMapAnnotation* mapAnnotation = [deal createMapAnnotation];

        [deal setAnnotation:mapAnnotation];
        
        [mutableAnnotations addObject:mapAnnotation];
        
    }
    
    return mutableAnnotations.copy;
    
}

-(void)cancelOperations:(generalBlockResponse)completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.sessionManager.operationQueue cancelAllOperations];
        [self.sessionManager.operationQueue waitUntilAllOperationsAreFinished];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            NSLog(@"Done canceling");
            
            completionHandler(YES);
            
        });
        
    });

}

#pragma mark -
#pragma mark - Web Socket Delegate Methods



@end
