//
//  DatabaseEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DatabaseEngine.h"
#import "AppDelegate.h"
#import "CityDataObject.h"
#import "Deal.h"
#import "ImageData.h"
#import "UIImage+Resizing.h"
#import "UIImageView+AFNetworking.h"

#define SEARCH_DEALS @"search"
#define TEMP_SEARCH_RESULTS @"tempsearch"
#define API_PLACES @"places"
#define HTTP_POST_METHOD @"POST"
#define KEY_EMPTY_VALUES @"emptyValues"
#define KEY_ERROR @"error"
#define KEY_DEALS @"deals"
#define KEY_LIST @"parsedList"
#define DEAL_COUNT @"count"
#define DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.sssZ"

#define RESCALE_IMAGE_WIDTH 1024
#define RESCALE_IMAGE_HEIGHT 1024

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
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
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
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    CityDataObject* city = appDelegate.locationManager.getCurrentLocationCityObject;
    
    NSString* cityName = city.name;
    
    NSString* state = city.state;
    
    NSString* currentDate = [self currentDateString];
    
    NSLog(@"%@", currentDate);
    
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

-(NSString*)convertUTCDateToLocal:(NSString*)utcDate
{
    if(!utcDate) return nil;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = DATE_FORMAT;
    
    NSDate* date = [formatter dateFromString:utcDate];
    
    if(!date) return nil;
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    
    NSISO8601DateFormatOptions options = NSISO8601DateFormatWithInternetDateTime | NSISO8601DateFormatWithDashSeparatorInDate | NSISO8601DateFormatWithColonSeparatorInTime | NSISO8601DateFormatWithTimeZone;
    
    NSString* localTime = [NSISO8601DateFormatter stringFromDate:date timeZone:timeZone formatOptions:options];
    
    return localTime;
}

-(void)sendSearchCriteriaForTotalCountOnly:(NSDictionary *)searchCriteria addCompletion:(dataResponseBlockResponse)completionBlock
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSLog(@"%@", searchCriteria);
    
    [self.sessionManager POST:TEMP_SEARCH_RESULTS parameters:searchCriteria progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if (responseObject) {
            
            BOOL isEmpty = [[responseObject valueForKey:KEY_EMPTY_VALUES] boolValue];
            
            if (isEmpty) {
                
                NSString* errorMessage = [responseObject valueForKey:KEY_ERROR];
                
                completionBlock(errorMessage);
            }
            else{
                
                NSArray* list = [responseObject valueForKey:KEY_LIST];
                
                NSDictionary* obj = list[0];
                
                NSInteger intTotal = [[obj valueForKey:DEAL_COUNT] integerValue];
                
                NSNumber* total = [NSNumber numberWithInteger:intTotal];
                
                completionBlock(total);
                
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        [self logFailedRequest:task];
        [self.delegate dealsFailedWithError:error];
        
    }];
}

-(void)sendSearchCriteria:(NSDictionary *)searchCriteria addCompletion:(dataResponseBlockResponse)completionBlock
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self.sessionManager POST:SEARCH_DEALS parameters:searchCriteria progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if (responseObject) {

            NSArray* deals = [responseObject valueForKey:KEY_DEALS];
            
            NSInteger total = deals.count;
            
            if (total <= 0) {
                
                NSString* errorMessage = [responseObject valueForKey:KEY_ERROR];
                
                NSLog(@"%@", errorMessage);
                
                NSArray* array = [[NSArray alloc] init];

                completionBlock(array);
            }
            else{
                
                NSLog(@"%@", deals);
                
                completionBlock(deals);
                
            }
            
        }
        else completionBlock(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        //[self.delegate dealsFailedWithError:error];
        completionBlock(error);
    }];
    
}

-(void)sendAddressForGeocode:(NSDictionary *)params addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    if(!params) return;
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self.sessionManager POST:API_PLACES parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(!responseObject) completionHandler(nil);
        
        completionHandler(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [self logFailedRequest:task];
        completionHandler(error);
        //[self.delegate dealsFailedWithError:error];
    }];
    
 
}

#warning needs better error handling
-(void)sendAddressesForGeocode:(NSDictionary *)params addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    if(!params) return;
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self.sessionManager POST:API_PLACES parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(!responseObject) completionHandler(nil);
        
        completionHandler(responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(NSDictionary *)parseGeocodeLocation:(NSDictionary *)locationInfo
{
    if(!locationInfo) return nil;
    
    NSString* formattedAddress = [locationInfo valueForKey:@"formatted_address"];
    
    NSDictionary* geometry = [locationInfo valueForKey:@"geometry"];
    
    NSArray* preferredCoords = [geometry valueForKey:@"viewport"];
    
    NSArray* coordinatesArray = [preferredCoords valueForKey:@"northeast"];
    
    NSDictionary* coordinates = [coordinatesArray objectAtIndex:0];
    
    //NSLog(@"%@", coordinates);
    
    NSString* locationType = [geometry valueForKey:@"location_type"];
    
    NSString* googlePlaceID = [locationInfo valueForKey:@"place_id"];
    
    NSMutableDictionary* mutableParsedInfo = [[NSMutableDictionary alloc] init];
    
    [mutableParsedInfo setValue:formattedAddress forKey:@"formatted_address"];
    [mutableParsedInfo setValue:coordinates forKey:@"coordinates"];
    [mutableParsedInfo setValue:locationType forKey:@"location_type"];
    [mutableParsedInfo setValue:googlePlaceID forKey:@"place_id"];
    
    NSDictionary* parsedInfo = mutableParsedInfo.copy;
    
    if(!parsedInfo) return nil;
    
    return parsedInfo;
}


-(void)downloadImageFromURL:(NSString *)urlString forImageView:(UIImageView *)imageView addCompletionHandler:(fetchedDataResponse)completionHandler{
    
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
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

-(void)downloadImageFromURL:(NSString *)urlSting addCompletionHandler:(fetchedDataResponse)completionHandler
{
    self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager GET:urlSting parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"Image fetched %@", responseObject);
        
        NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[task response]);
        
        completionHandler(responseObject, response, task.originalRequest);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
}

-(void)getImageFromCacheWithKey:(NSString *)key addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        if(!key) completionHandler(nil);
        else{
            
            id imgObject = [appDelegate.imageDataCache objectForKey:key];
            
            if(!imgObject) completionHandler(nil);
            else completionHandler(imgObject);
        }
    });
    
}

-(void)getImageFromCachePersistenceStorageWithKey:(NSString *)key addCompletionHandler:(dataResponseBlockResponse)completionHandler
{
    if(!key) completionHandler(nil);
    else{
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [appDelegate.imageDataCache getFileFromPersistentStorageCache:key addCompletion:^(id object) {
            
            if(!object) completionHandler(nil);
            else{
                
                UIImage* img = [UIImage imageWithData:object];
                
                if(!img) completionHandler(nil);
                else completionHandler(img);

            }
            
        }];
        
    }
    
}


-(void)cacheImage:(UIImage *)img forKey:(NSString *)key addCompletionHandler:(generalBlockResponse)completionHandler
{
    if(!img || !key) completionHandler(NO);
    else{
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [appDelegate.imageDataCache setObject:img forKey:key];
        
        completionHandler(YES);
    }
    
}

-(void)saveToCachePersistenceStorageImage:(UIImage *)img forKey:(NSString *)key addCompletionHandler:(generalBlockResponse)completionHandler
{
    if(!img || !key) completionHandler(NO);
    else{
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        NSData* imgData = UIImagePNGRepresentation(img);
        
        NSArray* stringComponents = [key componentsSeparatedByString:@"/"];
        
        NSString* imgName = [stringComponents lastObject];
        
        [appDelegate.imageDataCache saveFileToPersistentStorageCache:imgData withKey:imgName addCompletion:^(BOOL success) {
            
            if(success == NO) completionHandler(nil);
            else completionHandler(YES);
            
        }];
        
    }

}

#pragma mark -
#pragma mark - Sort Methods
-(void)sortArray:(NSArray *)array byKey:(NSString *)key ascending:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletion:(dataResponseBlockResponse)completionHandler
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
-(NSArray *)extractAddressFromDeals:(NSArray *)deals
{
    if(!deals) return nil;
    
    NSMutableArray* tmpAddresses = [[NSMutableArray alloc] initWithCapacity:deals.count];
    
    for (Deal* deal in deals) {
        NSString* address = deal.addressString;
        
        [tmpAddresses addObject:address];
    }
    
    NSArray* addresses = tmpAddresses.copy;
    
    return addresses;
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
    
    [self.sessionManager.operationQueue cancelAllOperations];
    
    [self.delegate operationsCancelled];
}

@end
