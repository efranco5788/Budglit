//
//  DatabaseManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//


#import "Manager.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>


@class DatabaseEngine;
@class Deal;
@class DealParser;
@class InstagramObject;
@class ImageDataCache;
@class FilterViewController;
@class LocationSeviceManager;

@protocol DatabaseManagerDelegate <NSObject>
@optional
-(void)managerRequestFailed;
-(void)managerHostBackOnline;
-(void)managerDealsDidNotLoad;
-(void)managerUserNotAuthenticated;
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage*)image andImageView:(UIImageView*)imageView;
@end

@interface DatabaseManager : Manager
{
    sqlite3* database;
}

typedef NS_ENUM(NSInteger, FilterType){
    FilterTypeBudget,
    FilterTypeDistance
};


+(id) sharedDatabaseManager;

@property (nonatomic, strong) NSDictionary* usersCurrentCriteria;
@property (nonatomic, strong) UIImageView* tmpImageView;
@property (nonatomic, strong) DealParser* dealParser;
@property (nonatomic, strong) id<DatabaseManagerDelegate> delegate;
@property (nonatomic, strong) DatabaseEngine* engine;
@property (nonatomic, strong) NSString* currentDate;

@property (NS_NONATOMIC_IOSONLY, getter=getZipcode, readonly, copy) NSString *zipcode;
@property (NS_NONATOMIC_IOSONLY, readonly) int closeDB;

-(NSArray*)managerGetSavedDeals;

-(NSDate*)managerGetTimestamp;

-(void)managerConstructWebSocket:(NSString*)token addCompletionBlock:(dataBlockResponse)completionHandler;

-(NSDictionary*)managerFetchPrimaryDefaultSearchFiltersWithLocation;

-(void)managerFetchDeals:(NSDictionary*)searchCriteria addCompletionBlock:(dataBlockResponse)completionHandler;

-(void)managerFetchDeals:(NSDictionary *)searchCriteria shouldClearCurrentDeals:(BOOL)shouldClear addCompletionBlock:(dataBlockResponse)completionHandler;

-(void)managerFetchCachedImageForKey:(NSString*)key addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerFetchPersistentStorageCachedImageForKey:(NSString*)key deal:(Deal*)aDeal addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerFetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler;

-(void)managerFetchGeocodeForAddress:(NSString*)address additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(void)managerFetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(NSArray*)managerExtractAddressesFromDeals:(NSArray*)deals;

-(void)managerStartDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerCancelDownloads:(generalCompletionHandler)completionHandler;

-(void)managerSortDeals:(NSArray*)deals byKey:(NSString*)key ascendingOrder:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletetion:(dataBlockResponse)completionHandler;

-(NSDictionary*)managerGetUsersCurrentCriteria;

-(NSString*)managerGetCurrentDateString;

-(NSArray*)managerFilterDeals:(NSArray*)deals byType:(FilterType)type filterCriteria:(double)criteria;

-(NSArray*)managerCreateMapAnnotationsForDeals:(NSArray*)deals;

-(NSInteger)managerGetLowestBudgetFromDeals:(NSArray*)deals;

-(NSInteger)managerGetHighestBudgetFromDeals:(NSArray*)deals;

-(void)managerSaveUsersCriteria:(NSDictionary*)usersCriteria;

-(void)managerSetZipcodeCriteria:(NSString*)zipcode;

-(BOOL)managerSaveFetchedDeals:(NSArray*)dealsFetched;

-(BOOL)managerUpdateFetechedDeals:(NSArray*)newDeals;

-(void)managerSaveStandardizedAddressesForDeals:(NSArray*)info;

-(void)managerResetDeals;

-(void)managerClearSearchFilter;

@end
