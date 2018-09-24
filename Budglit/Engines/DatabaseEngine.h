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

typedef void (^fetchedImageDataResponse)(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request);


@protocol DatabaseEngineDelegate <NSObject>
@optional
-(void)totalDealCountFailedWithError:(NSError*)error;
-(void)dealsFailedWithError:(NSError*)error;
-(void)operationsCancelled;

@end

@interface DatabaseEngine : Engine

@property (nonatomic, strong) id <DatabaseEngineDelegate> delegate;


-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)constructWebSocket:(NSString*)token addCompletion:(blockResponse)completionHandler;

-(void)setSocketEventsAddCompletion:(blockResponse)completionHandler;

// Constructs the basic default data for the app
-(NSDictionary*)constructDefaultFetchingObjects;

-(void)saveFetchingObjects:(NSDictionary*)objects addCompletion:(generalBlockResponse)completionHandler;

-(NSValue*)calculateCoordinateFrom:(NSValue*)coordinateValue onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres;

-(NSDictionary*)primaryDefaultForSearchFilterAtLocation;

-(void)sortArray:(NSArray*)array byKey:(NSString*)key ascending:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletion:(blockResponse)completionHandler;

-(void)sendGetRequestSearchCriteria:(NSDictionary*)searchCriteria addCompletion:(blockResponse) completionBlock;

-(void)sendSearchCriteria:(NSDictionary*)searchCriteria addCompletion:(blockResponse) completionBlock;

-(void)sendAddressForGeocode:(NSDictionary*)params addCompletionHandler:(blockResponse)completionHandler;

-(void)sendAddressesForGeocode:(NSDictionary*)params addCompletionHandler:(blockResponse)completionHandler;

-(void)downloadImageFromURL:(NSString*)urlString forImageView:(UIImageView*)imageView addCompletionHandler:(fetchedImageDataResponse)completionHandler;

-(void)downloadImageFromURL:(NSString*)urlSting addCompletionHandler:(fetchedImageDataResponse)completionHandler;

-(void)cacheImage:(UIImage*)img forKey:(NSString*)key addCompletionHandler:(generalBlockResponse)completionHandler;

-(void)saveToCachePersistenceStorageImage:(UIImage*)img forKey:(NSString*)key addCompletionHandler:(generalBlockResponse)completionHandler;

-(void)getImageFromCacheWithKey:(NSString*)key addCompletionHandler:(blockResponse)completionHandler;

-(void)getImageFromCachePersistenceStorageWithKey:(NSString*)key addCompletionHandler:(blockResponse)completionHandler;

-(BOOL)extractAuthetication:(NSDictionary*)info;

-(NSArray*)extractDeals:(NSDictionary*)info;

-(NSArray*)extractAddressFromDeals:(NSArray*)deals;

-(NSArray*)createMapAnnotationsForDeals:(NSArray*)deals addressInfo:(NSArray*)info;

-(NSArray*)filterOutDeals:(NSArray*)deals byBudgetAmount:(double)amount;

-(NSArray*)filterOutDeals:(NSArray*)deals byDistance:(double)distance;

-(NSInteger)findLowestBudget:(NSArray*)deals;

-(NSInteger)findHighestBudget:(NSArray*)deals;

-(NSDictionary*)parseGeocodeLocation:(NSDictionary*)locationInfo;

-(NSString*)currentDateString;

-(void) cancelOperations:(generalBlockResponse)completionHandler;

@end
