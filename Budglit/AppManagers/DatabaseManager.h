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
-(void)userNotAuthenticated;
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage*)image andImageView:(UIImageView*)imageView;
-(void)imageFetchedForDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage*)image andImageView:(UIImageView*)imageView;
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

-(NSDictionary*)managerFetchPrimaryDefaultSearchFiltersWithLocation;

-(void)managerFetchDeals:(NSDictionary*)searchCriteria addCompletionBlock:(dataBlockResponse)completionHandler;

-(void)managerFetchCachedImageForKey:(NSString*)key addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerFetchPersistentStorageCachedImageForKey:(NSString*)key deal:(Deal*)aDeal addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerFetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler;

-(void)managerFetchGeocodeForAddress:(NSString*)address additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(void)managerFetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary*)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler;

-(void)managerStartDownloadImageFromURLString:(NSString*)requestString forDeal:(Deal*)deal addCompletion:(fetchedImageResponse)completionHandler;

-(void)managerStartDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;

-(void)managerStartDownloadImageFromURL:(NSString *)url forDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;

-(void)managerStartDownloadImageFromURL:(NSString *)url forIndexPath:(NSIndexPath*)indexPath andImageView:(UIImageView*)imgView;

-(void)managerCancelDownloads:(generalBlockResponse)completionHandler;

-(void)managerSortDeals:(NSArray*)deals byKey:(NSString*)key ascendingOrder:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletetion:(dataBlockResponse)completionHandler;

-(NSDictionary*)managerGetUsersCurrentCriteria;

-(NSString*)managerGetCurrentDateString;

-(NSArray*)managerExtractDeals:(NSArray*)filteredDeals fromDeals:(NSArray*)deals;

-(NSArray*)managerFilterDeals:(NSArray*)deals byBudget:(double)budget;

-(NSArray*)managerCreateMapAnnotationsForDeals:(NSArray*)deals addressInfo:(NSArray*)info;

-(NSInteger)managerGetLowestBudgetFromDeals:(NSArray*)deals;

-(NSInteger)managerGetHighestBudgetFromDeals:(NSArray*)deals;

-(void)managerSaveUsersCriteria:(NSDictionary*)usersCriteria;

-(void)managerSetZipcodeCriteria:(NSString*)zipcode;

-(BOOL)managerSaveFetchedDeals:(NSArray*)dealsFetched;

-(NSArray*)managerGetSavedDeals;

-(void)managerResetDeals;

@end
