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
@class BudgetPickerViewController;
@class LocationSeviceManager;


typedef void (^fetchedImageResponse)(UIImage* image);
typedef void (^generalBlockResponse)(BOOL success);

@protocol DatabaseManagerDelegate <NSObject>
@optional
-(void)DealsDidLoad:(BOOL)result;
-(void)DealsDidNotLoad;
-(void)DisplayDealsOnMap:(NSMutableArray*) fetchedDeals;
-(void)TotalCountReturned:(NSInteger) totalCount;
-(void)totalCountSucess;
-(void)totalCountFailed;
-(void)totalCountReattempt:(NSDictionary*) criteria;
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

@property (nonatomic, strong) id<DatabaseManagerDelegate> delegate;

@property (nonatomic, strong) DatabaseEngine* engine;

-(id) initWithEngineHostName:(NSString*)hostName;

-(void) fetchDeals: (NSDictionary*) searchCriteria;

-(void) fetchDealsForMapView: (NSDictionary*) searchCriteria;

-(void) fetchTotalDealCountOnly: (NSDictionary*) searchCriteria andSender:(id) sender;

-(void) fetchImageForRequest:(NSURLRequest*)request addCompletion:(fetchedImageResponse)completionHandler;

-(void)startDownloadImageFromURL:(NSString *)url forDeal:(Deal*)deal forIndexPath:(NSIndexPath*)indexPath imageView:(UIImageView*)imgView;

-(void)cancelDownloads:(generalBlockResponse)completionHandler;

-(NSInteger)totalCountDealsLoaded;

-(void)resetDeals;

-(void) saveUsersCriteria:(NSDictionary*)usersCriteria;

-(NSDictionary*) getUsersCurrentCriteria;

-(NSString*) getCurrentDate;

-(NSString*) getZipcode;

-(void) setZipcodeCriteria:(NSString*)zipcode;

-(int)closeDB;

@end