//
//  DatabaseEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

@class AppDelegate;
@class Deal;
@class DealMapAnnotation;
@class ImageData;

typedef void (^fetchedDataResponse)(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request);
typedef void (^dataResponseBlockResponse)(id response);


@protocol DatabaseEngineDelegate <NSObject>
-(void)totalDealCountReturned:(NSInteger)responseCount;
-(void)totalDealCountFailedWithError:(NSError*)error;
-(void)dealsReturned:(NSArray*)deals;
-(void)dealsFailedWithError:(NSError*)error;
-(void)operationsCancelled;
@optional

@end

@interface DatabaseEngine : Engine

@property (nonatomic, strong) id <DatabaseEngineDelegate> delegate;

-(NSValue*)calculateCoordinateFrom:(NSValue*)coordinateValue onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres;
-(instancetype)init;
-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;
-(NSDictionary*)primaryDefaultForSearchFilterWithZipcodes:(NSArray*)zipcodes;
-(void)sendSearchCriteriaForTotalCountOnly:(NSDictionary*)searchCriteria addCompletion:(dataResponseBlockResponse) completionBlock;
-(void)sendSearchCriteria:(NSDictionary*)searchCriteria addCompletion:(dataResponseBlockResponse) completionBlock;
-(void)sendAddressForGeocode:(NSDictionary*)params parseAfterCompletion:(BOOL)willParse addCompletionHandler:(dataResponseBlockResponse)completionHandler;
-(void)sendAddressesForGeocode:(NSDictionary*)params parseAfterCompletion:(BOOL)willParse addCompletionHandler:(dataResponseBlockResponse)completionHandler;
-(void)downloadImageFromURL:(NSString*)urlString forImageView:(UIImageView*)imageView addCompletionHandler:(fetchedDataResponse)completionHandler;
-(void)downloadImageFromRequest:(NSURLRequest*)request addCompletionHandler:(fetchedDataResponse)completionHandler;
-(void)cacheImage:(UIImage*)img forKey:(NSString*)key;
-(UIImage*)getImageFromCacheWithKey:(NSString*)key;
-(void)groupAnnotationByCoordinates:(NSMutableArray*)annotations addCompletionHandler:(dataResponseBlockResponse)completionHandler;
-(void)attemptToRepositionAnnotations:(id)annotations addCompletionHandler:(generalBlockResponse)completionHandler;
-(NSArray*)extractAddressFromDeals:(NSArray*)deals;
-(NSDictionary*)parseGeocodeLocation:(NSDictionary*)locationInfo;
-(NSString*)getCurrentDate;
-(void) cancelOperations:(generalBlockResponse)completionHandler;

@end
