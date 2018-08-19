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
@optional
-(void)totalDealCountFailedWithError:(NSError*)error;
-(void)dealsFailedWithError:(NSError*)error;
-(void)operationsCancelled;

@end

@interface DatabaseEngine : Engine

@property (nonatomic, strong) id <DatabaseEngineDelegate> delegate;

-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

// Constructs the basic default data for the app
-(NSDictionary*)constructDefaultFetchingObjects;

-(void)saveFetchingObjects:(NSDictionary*)objects addCompletion:(generalBlockResponse)completionHandler;

-(NSValue*)calculateCoordinateFrom:(NSValue*)coordinateValue onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres;

-(NSDictionary*)primaryDefaultForSearchFilterAtLocation;

-(void)sortArray:(NSArray*)array byKey:(NSString*)key ascending:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletion:(dataResponseBlockResponse)completionHandler;

-(void)sendSearchCriteriaForTotalCountOnly:(NSDictionary*)searchCriteria addCompletion:(dataResponseBlockResponse) completionBlock;

-(void)sendGetRequestSearchCriteria:(NSDictionary*)searchCriteria addCompletion:(dataResponseBlockResponse) completionBlock;

-(void)sendSearchCriteria:(NSDictionary*)searchCriteria addCompletion:(dataResponseBlockResponse) completionBlock;

-(void)sendAddressForGeocode:(NSDictionary*)params addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)sendAddressesForGeocode:(NSDictionary*)params addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)downloadImageFromURL:(NSString*)urlString forImageView:(UIImageView*)imageView addCompletionHandler:(fetchedDataResponse)completionHandler;

-(void)downloadImageFromURL:(NSString*)urlSting addCompletionHandler:(fetchedDataResponse)completionHandler;

-(void)cacheImage:(UIImage*)img forKey:(NSString*)key addCompletionHandler:(generalBlockResponse)completionHandler;

-(void)saveToCachePersistenceStorageImage:(UIImage*)img forKey:(NSString*)key addCompletionHandler:(generalBlockResponse)completionHandler;

-(void)getImageFromCacheWithKey:(NSString*)key addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)getImageFromCachePersistenceStorageWithKey:(NSString*)key addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)groupAnnotationByCoordinates:(NSMutableArray*)annotations addCompletionHandler:(dataResponseBlockResponse)completionHandler;

-(void)attemptToRepositionAnnotations:(id)annotations addCompletionHandler:(generalBlockResponse)completionHandler;

-(BOOL)extractAuthetication:(NSDictionary*)info;

-(NSArray*)extractDeals:(NSDictionary*)info;

-(NSArray*)extractAddressFromDeals:(NSArray*)deals;

-(NSArray*)filterOutDeals:(NSArray*)deals byBudgetAmount:(double)amount;

-(NSInteger)findLowestBudget:(NSArray*)deals;

-(NSInteger)findHighestBudget:(NSArray*)deals;

-(NSDictionary*)parseGeocodeLocation:(NSDictionary*)locationInfo;

-(NSString*)currentDateString;

-(void) cancelOperations:(generalBlockResponse)completionHandler;

@end
