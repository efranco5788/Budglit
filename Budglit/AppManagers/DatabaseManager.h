//
//  DatabaseManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>


@class DatabaseEngine;
@class Deal;
@class DealParser;
@class InstagramObject;
@class BudgetPickerViewController;
@class LocationSeviceManager;

typedef void (^fetchedImageResponse)(UIImage* image);
typedef void (^generalBlockResponse)(BOOL success);
typedef void (^dataBlockResponse)(id response);
typedef void (^newDataFetchedResponse)(UIBackgroundFetchResult result);

@protocol DatabaseManagerDelegate <NSObject>
@optional
-(void)dealsDidNotLoad;
-(void)totalCountFailed;
-(void)totalCountReattempt:(NSDictionary*) criteria;
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage*)image andImageView:(UIImageView*)imageView;
-(void)imageFetchedForDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage*)image andImageView:(UIImageView*)imageView;
-(void)imagesFetched;
@end

@interface DatabaseManager : NSObject
{
    sqlite3* database;
    NSInteger totalLoadedDeals_Count;
}

+(DatabaseManager*) sharedDatabaseManager;

@property (nonatomic, strong) NSDictionary* usersCurrentCriteria;
@property (nonatomic, strong) UIImageView* tmpImageView;
@property (nonatomic, strong) DealParser* dealParser;
@property (nonatomic, strong) id<DatabaseManagerDelegate> delegate;
@property (nonatomic, strong) DatabaseEngine* engine;
@property (nonatomic, strong) NSString* currentDate;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger totalCountDealsLoaded;
@property (NS_NONATOMIC_IOSONLY, getter=getZipcode, readonly, copy) NSString *zipcode;
@property (NS_NONATOMIC_IOSONLY, readonly) int closeDB;

-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)fetchDeals: (NSDictionary*)searchCriteria addCompletionBlock:(generalBlockResponse)completionHandler;

-(void)fetchTotalDealCountOnly: (NSDictionary*)searchCriteria addCompletionBlock:(generalBlockResponse)completionHandler;

-(NSDictionary*)fetchPrimaryDefaultSearchFiltersWithZipcodes:(NSArray*)zipcodes;

-(NSDictionary*)fetchPrimaryDefaultSearchFiltersWithLocation;

-(void)fetchCachedImageForKey:(NSString*)key addCompletion:(fetchedImageResponse)completionHandler;

-(void)fetchPersistentStorageCachedImageForKey:(NSString*)key deal:(Deal*)aDeal addCompletion:(fetchedImageResponse)completionHandler;

-(void)fetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler;

-(void)fetchGeocodeForAddress:(NSString*)address additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(void)fetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(void)startDownloadImageFromURLString:(NSString*)requestString forDeal:(Deal*)deal addCompletion:(fetchedImageResponse)completionHandler;

-(void)startDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;

-(void)startDownloadImageFromURL:(NSString *)url forDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;

-(void)startDownloadImageFromURL:(NSString *)url forIndexPath:(NSIndexPath*)indexPath andImageView:(UIImageView*)imgView;

-(void)cancelDownloads:(generalBlockResponse)completionHandler;

-(void)sortDeals:(NSArray*)deals byKey:(NSString*)key ascendingOrder:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletetion:(dataBlockResponse)completionHandler;

-(NSDictionary*)getUsersCurrentCriteria;

-(void)saveUsersCriteria:(NSDictionary*)usersCriteria;

-(void)setZipcodeCriteria:(NSString*)zipcode;

-(NSString*)getCurrentDate;

-(NSArray*)getSavedDeals;

-(void)resetDeals;

@end
