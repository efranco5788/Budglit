//
//  DatabaseManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DatabaseManager.h"
#import <dispatch/dispatch.h>
#import "AppDelegate.h"
#import "DatabaseEngine.h"
#import "BudgetPickerViewController.h"
#import "Deal.h"
#import "DealParser.h"
#import "DealTableViewCell.h"
#import "InstagramObject.h"

#define DEFAULT_ATTEMPT_RETRIES 1

#define SQLITE_DB_NAME @"PSOfflineZipcodeDB"

#define KEY_FOR_RETURNED_DEALS @"allDeals"
#define KEY_FOR_TOTAL_COUNT @"totalDeals"

static DatabaseManager* sharedManager;

@interface DatabaseManager()<DatabaseEngineDelegate>
{
    dispatch_queue_t backgroundQueue;
    NSInteger totalCountAttempts;
}
@end

@implementation DatabaseManager
@synthesize currentDeals;

+(DatabaseManager *)sharedDatabaseManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

-(id)init {
    
    return [self initWithEngineHostName:nil];
}

-(id)initWithEngineHostName:(NSString *)hostName
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[DatabaseEngine alloc] initWithHostName:hostName];
    
    self.dealParser = [[DealParser alloc] initParser];
    
    [self.engine setDelegate:self];
    
    self.currentDeals = [[NSMutableArray alloc] init];
    
    NSString* sqliteDB = [[NSBundle mainBundle] pathForResource:SQLITE_DB_NAME ofType:@"sqlite3"];
    
    if(sqlite3_open([sqliteDB UTF8String], &database) != SQLITE_OK){
        NSLog(@"Failed to open database");
    }
    else{
        NSLog(@"database connection SUCCESS.");
    }
    
    return self;
}

-(void)setZipcodeCriteria:(NSString *)zipcode
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSMutableDictionary* newCriteria = [[NSMutableDictionary alloc] init];
    
    NSArray* keys = [searchFilters allKeys];
    NSArray* values = [searchFilters allValues];
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [newCriteria addEntriesFromDictionary:critera];

    [newCriteria setObject:zipcode forKey:NSLocalizedString(@"ZIPCODE", nil)];
    
    [self saveUsersCriteria:newCriteria];
    
}

-(void)saveUsersCriteria:(NSDictionary *)usersCriteria
{
    NSDictionary* criteria = usersCriteria;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* savedCriteria = [defaults objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    if (savedCriteria != nil) {
        [defaults removeObjectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    }
    
    [defaults setValue:criteria forKeyPath:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    criteria = nil;
    savedCriteria = nil;
    defaults = nil;
}

-(NSDictionary *)getUsersCurrentCriteria
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSArray* keys = [searchFilters allKeys];
    NSArray* values = [searchFilters allValues];
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    keys = nil;
    values = nil;
    searchFilters = nil;
    
    return critera;
}

-(NSString*)getCurrentDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:NSLocalizedString(@"DATE_FORMAT", nil)];
    
    NSString* currentDate = [formatter stringFromDate:[NSDate date]];
    
    return currentDate;
}

-(NSString*)getZipcode
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSString* zipcode = [searchFilters objectForKey:NSLocalizedString(@"ZIPCODE", nil)];
    
    return zipcode;
}

-(int)closeDB
{
    int closeDB_Status = sqlite3_close(database);
    
    NSLog(@"Database sucessfully closed %d", closeDB_Status);
    
    return closeDB_Status;
}

-(void)fetchDeals:(NSDictionary *)searchCriteria
{
    NSDictionary* criteria;
    
    if (searchCriteria == nil) {
        
        criteria = [self getUsersCurrentCriteria];
    }
    else criteria = searchCriteria;
    
    [self.engine sendSearchCriteria:criteria];
    
}

-(void)fetchDealsForMapView:(NSDictionary *)searchCriteria
{
    NSDictionary* criteria;
    //NSMutableArray* fetchedDeals = [[NSMutableArray alloc] init];
    
    if (searchCriteria == nil) {
        
        criteria = [self getUsersCurrentCriteria];
    }
    else criteria = searchCriteria;
    
    //AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [self.engine sendSearchCriteria:criteria];
    
    dispatch_async(backgroundQueue, ^{
        
        //        [appDelegate.DBEngine sendSearchCriteria:criteria completionHandler:^(NSDictionary *deals){
        //
        //            if (deals == nil){
        //                [self.delegate DealsDidNotLoad];
        //            }
        //            else{
        //                NSDictionary* returnedDeals = deals;
        //
        //                NSDictionary* subDeals = [returnedDeals valueForKey:KEY_FOR_RETURNED_DEALS];
        //
        //                NSInteger count = (NSInteger) [[subDeals objectForKey:KEY_FOR_TOTAL_COUNT] integerValue];
        //
        //                // Check if any deals were returned
        //                if(count <= 0){
        //
        //                }
        //                else
        //                {
        //
        //                    for (id key in subDeals) {
        //                        if ([key isEqualToString:KEY_FOR_TOTAL_COUNT]) {
        //
        //                        }
        //                        else
        //                        {
        //
        //                            NSDictionary* deal = [subDeals valueForKey:key];
        //
        //                            NSString* dealDate = [deal objectForKey:KEY_DEAL_DATE];
        //
        //                            double dealBudget = [[deal objectForKey:KEY_DEAL_BUDGET] doubleValue];
        //
        //                            NSString* dealDescription = [deal objectForKey:KEY_DEAL_DESCRIPTION];
        //
        //                            NSString* venue = [deal objectForKey:KEY_VENUE_NAME];
        //
        //                            NSString* venueAddress = [deal objectForKey:KEY_VENUE_ADDRESS];
        //
        //                            NSString* venueCity = [deal objectForKey:KEY_VENUE_CITY];
        //
        //                            NSString* venueState = [deal objectForKey:KEY_VENUE_STATE];
        //
        //                            NSString* zipcode = [[deal objectForKey:KEY_VENUE_ZIPCODE] stringValue];
        //
        //                            NSString* venuePhone = [deal objectForKey:KEY_VENUE_PHONE_NUMBER];
        //
        //                            NSString* imgURL = [deal objectForKey:KEY_VENUE_IMAGE_URL];
        //
        //                            Deal* newDeal = [[Deal alloc] initWithVenueName:venue andVenueAddress:venueAddress andVenueDescription:nil andDate:dealDate andDealDescription:dealDescription andPhoneNumber:venuePhone andCity:venueCity andState:venueState andZipcode:zipcode andBudget:dealBudget andDealID:1 andURLImage:imgURL];
        //
        //                            [fetchedDeals addObject:newDeal];
        //
        //                        }// End of most inner else statment
        //
        //                    }// End of second to most inner else statement
        //
        //                    [self.delegate DisplayDealsOnMap:fetchedDeals];
        //
        //                }// End of third to most inner statement
        //
        //            }
        //
        //        } errorhandler:^(NSError *error) {
        //            DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
        //                 [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
        //
        //            [self.delegate DealsDidLoad:NO];
        //        }]; // End of DBEngine Method
        
    });// End of async Method
}


-(void)fetchTotalDealCountOnly:(NSDictionary *)searchCriteria andSender:(id)sender
{
    [self.engine sendSearchCriteriaForTotalCountOnly:searchCriteria];
}

-(void)fetchImageForRequest:(NSURLRequest *)request addCompletion:(fetchedImageResponse)completionHandler
{
    [self.engine downloadImageFromRequest:request addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        completionHandler(imageResponse);
        
    }];
}

-(void)fetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler
{
    
}

-(void)startDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView
{
    
    [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        BOOL imgExist = NO;
        
        if (imageResponse) {
            imgExist = YES;
        }
        
        if ([object isMemberOfClass:[InstagramObject class]]) {
            
            InstagramObject* obj = (InstagramObject*) object;
            
            [obj.mediaStateHandler recordImageHTTPResponse:response andRequest:request hasImage:imgExist];
            
            [self.delegate imageFetchedForObject:obj forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
            
        }
        else if ([object isMemberOfClass:[DealTableViewCell class]]){
            
            AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
            
            NSArray* list = appDelegate.databaseManager.currentDeals;
            
            Deal* objDeal = [list objectAtIndex:indexPath.row];
            
            [objDeal.imgStateObject recordImageHTTPResponse:response andRequest:request hasImage:imgExist];
            
            //[self.delegate imageFetchedForObject:objDeal forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
            
            [self.delegate imageFetchedForObject:object forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
        }
        
    }];
}

-(void)startDownloadImageFromURL:(NSString *)url forDeal:(Deal *)deal forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView
{
    
    [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request) {
        BOOL imageExist = NO;
        
        if (imageResponse) {
            imageExist = YES;
        }
        
        [deal.imgStateObject recordImageHTTPResponse:response andRequest:request hasImage:imageExist];
        
        [self.delegate imageFetchedForDeal:deal forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
        
    }];
}

// Methods to download general images
-(void)startDownloadImageFromURL:(NSString *)url forIndexPath:(NSIndexPath *)indexPath andImageView:(UIImageView *)imgView
{
    [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        [self.delegate imageFetchedForObject:nil forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
    }];
}

-(void)cancelDownloads:(generalBlockResponse)completionHandler
{
    [self.engine cancelOperations:^(BOOL success) {
        
        completionHandler(YES);
        
    }];
}

-(NSInteger)totalCountDealsLoaded
{
    return totalLoadedDeals_Count;
}

-(void) incrementTotalCountsAttempts
{
    totalCountAttempts++;
    NSLog(@"Attempt #%ld", (long)totalCountAttempts);
}

-(void) resetTotalCountsAttempts
{
    totalCountAttempts = 0;
    NSLog(@"Total count attempts has been reset");
}

-(void)resetDeals
{
    [self.currentDeals removeAllObjects];
    totalLoadedDeals_Count = 0;
    NSLog(@"Deals removed!");
}

#pragma mark -
#pragma mark - Database Engine delegates
-(void)totalDealCountReturned:(NSInteger)responseCount
{
    totalLoadedDeals_Count = responseCount;
    
    [self.delegate totalCountSucess];
    
}

-(void)totalDealCountFailedWithError:(NSError *)error
{
    
}

-(void)dealsReturned:(NSArray *)deals
{
    // Reset Deals first
    [self resetDeals];
    
    [self.dealParser parseDeals:deals addCompletionHandler:^(NSArray *parsedList) {
        if (parsedList) {
            
            NSLog(@"%@", parsedList);
            
            for (Deal* node in parsedList) {
                [self.currentDeals addObject:node];
            }
            
            [self.delegate DealsDidLoad:YES];
            
        }
    }];
    
}

-(void)dealsFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    [self.delegate DealsDidNotLoad];
}

-(void)operationsCancelled
{
    NSLog(@"Operations Cancelled");
    
    
}

@end
