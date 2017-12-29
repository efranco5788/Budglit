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
-(void)DealsDidLoad:(BOOL)result;
-(void)DealsDidNotLoad;
-(void)DisplayDealsOnMap:(NSMutableArray*) fetchedDeals;
-(void)TotalCountReturned:(NSInteger) totalCount;
-(void)totalCountSucess;
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

@property (nonatomic, strong) NSMutableArray* currentDeals;
@property (nonatomic, strong) UIImageView* tmpImageView;
@property (nonatomic, strong) DealParser* dealParser;
@property (nonatomic, strong) id<DatabaseManagerDelegate> delegate;
@property (nonatomic, strong) DatabaseEngine* engine;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger totalCountDealsLoaded;
@property (NS_NONATOMIC_IOSONLY, getter=getUsersCurrentCriteria, readonly, copy) NSDictionary *usersCurrentCriteria;
@property (NS_NONATOMIC_IOSONLY, getter=getCurrentDate, readonly, copy) NSString *currentDate;
@property (NS_NONATOMIC_IOSONLY, getter=getZipcode, readonly, copy) NSString *zipcode;
@property (NS_NONATOMIC_IOSONLY, readonly) int closeDB;

-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)fetchDeals: (NSDictionary*) searchCriteria;
-(void)fetchDealsForMapView: (NSDictionary*) searchCriteria;
-(void)fetchTotalDealCountOnly: (NSDictionary*) searchCriteria andSender:(id) sender;
-(NSDictionary*)fetchPrimaryDefaultSearchFiltersWithZipcodes:(NSArray*)zipcodes;
-(void)fetchImageForRequest:(NSURLRequest*)request addCompletion:(fetchedImageResponse)completionHandler;
-(void)fetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler;
-(void)fetchGeocodeForAddress:(NSString*)address additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;
-(void)fetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;
-(void)startDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;
-(void)startDownloadImageFromURL:(NSString *)url forDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;
-(void)startDownloadImageFromURL:(NSString *)url forIndexPath:(NSIndexPath*)indexPath andImageView:(UIImageView*)imgView;
-(void)cancelDownloads:(generalBlockResponse)completionHandler;
-(NSMutableDictionary*)getDefaultSearchFilters;
-(void)saveUsersCriteria:(NSDictionary*)usersCriteria;
-(void)setZipcodeCriteria:(NSString*)zipcode;
-(void)resetDeals;

@end
