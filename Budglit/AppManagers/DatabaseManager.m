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

-(instancetype)init {
    
    return [self initWithEngineHostName:nil];
}

-(instancetype)initWithEngineHostName:(NSString *)hostName
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[DatabaseEngine alloc] initWithHostName:hostName];
    
    self.dealParser = [[DealParser alloc] initParser];
    
    (self.engine).delegate = self;
    
    self.currentDeals = [[NSMutableArray alloc] init];
    
    NSString* sqliteDB = [[NSBundle mainBundle] pathForResource:SQLITE_DB_NAME ofType:@"sqlite3"];
    
    if(sqlite3_open(sqliteDB.UTF8String, &database) != SQLITE_OK){
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
    
    NSArray* keys = searchFilters.allKeys;
    NSArray* values = searchFilters.allValues;
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [newCriteria addEntriesFromDictionary:critera];

    newCriteria[NSLocalizedString(@"ZIPCODE", nil)] = zipcode;
    
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
    
    NSArray* keys = searchFilters.allKeys;
    NSArray* values = searchFilters.allValues;
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    keys = nil;
    values = nil;
    searchFilters = nil;
    
    return critera;
}

-(NSString*)getZipcode
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSString* zipcode = searchFilters[NSLocalizedString(@"ZIPCODE", nil)];
    
    return zipcode;
}

-(int)closeDB
{
    int closeDB_Status = sqlite3_close(database);
    
    NSLog(@"Database sucessfully closed %d", closeDB_Status);
    
    return closeDB_Status;
}

-(NSDictionary *)fetchPrimaryDefaultSearchFiltersWithZipcodes:(NSArray *)zipcodes
{
    return [self.engine primaryDefaultForSearchFilterWithZipcodes:zipcodes];
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

-(void)fetchGeocodeForAddress:(NSString *)address additionalParams:(NSDictionary *)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler
{
    if(!address && !params) return;
    
    NSMutableDictionary* tmpMutableParameters = [[NSMutableDictionary alloc] init];
    
    if (address) {
        NSDictionary* parameters = [self.engine constructParameterWithKey:@"address" AndValue:address addToDictionary:params];
        tmpMutableParameters = parameters.mutableCopy;
    }
    
    if (params) {
        [tmpMutableParameters addEntriesFromDictionary:params];
    }
    
    NSDictionary* parameters = tmpMutableParameters.copy;
    
    [self.engine sendAddressForGeocode:parameters parseAfterCompletion:parse addCompletionHandler:^(id response) {
        completionHandler(response);
    }];
}

-(void)fetchGeocodeForAddresses:(NSArray *)addressList additionalParams:(NSDictionary *)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler
{
    NSMutableDictionary* tmpMutableParameters = [[NSMutableDictionary alloc] init];
    
    if(addressList){
        NSDictionary* parameters = [self.engine constructParameterWithKey:@"address" AndValue:addressList addToDictionary:params];
        tmpMutableParameters = parameters.mutableCopy;
    }
    
    if(params){
        [tmpMutableParameters addEntriesFromDictionary:params];
    }
    
    __block NSDictionary* preFinalParameters = tmpMutableParameters;
    
    NSArray* address = [preFinalParameters valueForKey:@"address"];
    
    NSArray* unorderedAddressList = [self.engine removeDuplicateFromArray:address Unordered:YES];
    
    [tmpMutableParameters setObject:unorderedAddressList forKey:@"address"];
    
    NSDictionary* finalParameters = tmpMutableParameters.copy;  
    
    [self.engine sendAddressesForGeocode:finalParameters parseAfterCompletion:YES addCompletionHandler:^(id response) {

        if(response){
            completionHandler(response);
        }
        
    }];
}

-(void)fetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler
{
    
}

-(void)startDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView
{
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
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
            
            NSArray* list = appDelegate.databaseManager.currentDeals;
            
            Deal* objDeal = list[indexPath.row];
            
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
            
        }
        
    }];
    
    [self.delegate DealsDidLoad:YES];
    
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
