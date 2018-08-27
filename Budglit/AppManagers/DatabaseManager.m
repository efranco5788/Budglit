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
#define KEY_ADDRESS @"address"

static DatabaseManager* sharedManager;

@interface DatabaseManager()<DatabaseEngineDelegate>
{
    dispatch_queue_t backgroundQueue;
    NSInteger totalCountAttempts;
}
@property (nonatomic, strong) NSArray* fetchedDeals;
@property (nonatomic, strong) NSDictionary* searchFilter;
@property (nonatomic, strong) NSArray* plottedMapAnnotations;
@end

@implementation DatabaseManager

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
    
    (self.engine).delegate = self;
    
    self.engine = [[DatabaseEngine alloc] initWithHostName:hostName];
    
    self.dealParser = [[DealParser alloc] initParser];
    
    self.plottedMapAnnotations = [[NSArray alloc] init];
    
    self.fetchedDeals = nil;
    
    NSString* sqliteDB = [[NSBundle mainBundle] pathForResource:SQLITE_DB_NAME ofType:@"sqlite3"];
    
    if(sqlite3_open(sqliteDB.UTF8String, &database) != SQLITE_OK){
        NSLog(@"Failed to open database");
    }
    else{
        NSLog(@"database connection SUCCESS.");
    }
    
    return self;
}

-(NSArray*)managerGetSavedDeals
{
    return self.fetchedDeals.copy;
}

-(BOOL)managerSaveFetchedDeals:(NSArray *)dealsFetched
{
    if(dealsFetched){
        
        self.fetchedDeals = dealsFetched;
        
        return YES;
    }
    else return NO;
}

-(void)managerSetZipcodeCriteria:(NSString *)zipcode
{
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSMutableDictionary* mutableFilterCopy = self.searchFilter.mutableCopy;
    
    //NSMutableDictionary* newCriteria = [[NSMutableDictionary alloc] init];
    
    /*
    NSArray* keys = self.searchFilter.allKeys;
    NSArray* values = self.searchFilter.allValues;
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [newCriteria addEntriesFromDictionary:critera];

    newCriteria[NSLocalizedString(@"ZIPCODE", nil)] = zipcode;
    
    [self saveUsersCriteria:newCriteria];
    */

    mutableFilterCopy[NSLocalizedString(@"ZIPCODE", nil)] = zipcode;
    
    [self managerSaveUsersCriteria:mutableFilterCopy.copy];
}

-(void)managerSaveUsersCriteria:(NSDictionary *)usersCriteria
{
    /*
    NSDictionary* criteria = usersCriteria;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* savedCriteria = [defaults objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    if (savedCriteria != nil) {
        [defaults removeObjectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    }
    
    [defaults setValue:criteria forKeyPath:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    [defaults synchronize];
     
    */
    
    self.searchFilter = usersCriteria;
}

-(NSDictionary *)managerGetUsersCurrentCriteria
{
    /*
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* searchFilters = [defaults valueForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSArray* keys = searchFilters.allKeys;
    NSArray* values = searchFilters.allValues;
    
    NSDictionary* critera = [NSDictionary dictionaryWithObjects:values forKeys:keys];

    return critera;
     
     */
    
    return self.searchFilter.copy;
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

-(NSDictionary *)managerFetchPrimaryDefaultSearchFiltersWithLocation
{
    return [self.engine primaryDefaultForSearchFilterAtLocation];
}

-(NSArray *)managerExtractDeals:(NSArray *)filteredDeals fromDeals:(NSArray *)deals
{
    if(!filteredDeals) return nil;
    
    NSMutableSet* newDealsSet;
    
    if (deals) newDealsSet = [NSMutableSet setWithArray:deals];
    else newDealsSet = [NSMutableSet setWithArray:self.managerGetSavedDeals];

    NSSet* filteredSet = [NSSet setWithArray:filteredDeals];
    
    [newDealsSet minusSet:filteredSet];
    
    NSArray* extractedDeals = [newDealsSet allObjects];
    
    if(!extractedDeals) return nil;
    
    return extractedDeals;
}

-(NSArray *)managerFilterDeals:(NSArray*)deals byBudget:(double)budget
{
    if(!deals){
        deals = [self managerGetSavedDeals];
    }
    
    NSPredicate* dealPredicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", [Deal class]];
    
    NSArray* foundDeals = [deals filteredArrayUsingPredicate:dealPredicate];
    
    if(!foundDeals || foundDeals.count < 1){
        return nil;
    }
    
    NSArray* filtered = [self.engine filterOutDeals:foundDeals byBudgetAmount:budget];
    
    return filtered;
    
}

-(NSInteger)managerGetLowestBudgetFromDeals:(NSArray*)deals
{
    if (!deals || deals.count < 1) return -1;
    
    return [self.engine findLowestBudget:deals.copy];
}

-(NSInteger)managerGetHighestBudgetFromDeals:(NSArray *)deals
{
    if(!deals || deals.count < 1) return -1;
    
    return [self.engine findHighestBudget:deals.copy];
    
}

#warning needs better error handling
-(void)managerFetchDeals:(NSDictionary *)searchCriteria addCompletionBlock:(dataBlockResponse)completionHandler
{
    // Fetches Deals from Server
    NSMutableArray* newDealArray = [[NSMutableArray alloc] init];
    
    if (searchCriteria == nil) searchCriteria = [[self managerGetUsersCurrentCriteria] copy];
    
    NSLog(@"%@", searchCriteria);
    
    [self.engine sendSearchCriteria:searchCriteria addCompletion:^(id response) {
        
        if(response){
            
            NSDictionary* dict = (NSDictionary*) response;
            
            BOOL authenticated = [self.engine extractAuthetication:dict];
            
            if(authenticated == FALSE) [self.delegate userNotAuthenticated];
            else{
                
                NSArray* deals = [self.engine extractDeals:dict];
                
                NSArray* parsedDeals = [self.dealParser parseDeals:deals];
                
                if(parsedDeals){
                    
                    for (Deal* node in parsedDeals) {
                        [newDealArray addObject:node];
                    }
                    
                    // reset and add current Deals
                    //[self resetDeals];
                    
                    //self.fetchedDeals = newDealArray.copy;
                    completionHandler(newDealArray);
                    
                }
                else completionHandler(nil);
                
            }
            
        }
        else completionHandler(nil);
        
    }];  //End of search criteria method
            
    
}

-(void)managerFetchGeocodeForAddress:(NSString *)address additionalParams:(NSDictionary *)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler
{
    if(!address && !params) return;
    
    NSMutableDictionary* tmpMutableParameters = [[NSMutableDictionary alloc] init];
    
    if (address) {
        NSDictionary* parameters = [self.engine constructParameterWithKey:KEY_ADDRESS AndValue:address addToDictionary:params];
        
        tmpMutableParameters = parameters.mutableCopy;
    }
    
    if (params) {
        [tmpMutableParameters addEntriesFromDictionary:params];
    }
    
    NSDictionary* parameters = tmpMutableParameters.copy;
    
    [self.engine sendAddressForGeocode:parameters addCompletionHandler:^(id response){
        
        if(!response) completionHandler(nil);
        else{
            
            if (!parse) completionHandler(response);
            
            NSDictionary* unparsedAddress = (NSDictionary*) response;
            
            NSDictionary* parsedAddress = [self.engine parseGeocodeLocation:unparsedAddress];
            
            completionHandler(parsedAddress);
            
        }
        
    }];
}

-(void)managerFetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary *)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler
{
    NSMutableDictionary* tmpMutableParameters = [[NSMutableDictionary alloc] init];
    
    if(addressList){
        NSDictionary* parameters = [self.engine constructParameterWithKey:KEY_ADDRESS AndValue:addressList addToDictionary:params];
        tmpMutableParameters = parameters.mutableCopy;
    }
    
    if(params){
        [tmpMutableParameters addEntriesFromDictionary:params];
    }
    
    NSArray* address = [tmpMutableParameters valueForKey:KEY_ADDRESS];
    
    NSArray* unorderedAddressList = [self.engine removeDuplicateFromArray:address Unordered:YES];
    
    [tmpMutableParameters setObject:unorderedAddressList forKey:KEY_ADDRESS];
    
    NSDictionary* finalParameters = tmpMutableParameters.copy;  
    
    [self.engine sendAddressesForGeocode:finalParameters addCompletionHandler:^(id response) {
        
        if(!response) completionHandler(nil);
        else{
            
            if(!parse) completionHandler(response);
            else{
                
                NSArray* addressList = (NSArray*) response;
                
                NSMutableArray* mutableParsedList = [[NSMutableArray alloc] init];
                
                for (NSDictionary* address in addressList) {
                    NSDictionary* parsedAddress = [self.engine parseGeocodeLocation:address];
                    [mutableParsedList addObject:parsedAddress];
                }
                
                NSDictionary* parsedList = mutableParsedList.copy;
                
                completionHandler(parsedList);
                
            }
            
        }
        
        
    }];
}

-(void)managerFetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler
{
    
}

// Fetch Memory Cahce for Image
-(void)fetchCachedImageForKey:(NSString *)key addCompletion:(fetchedImageResponse)completionHandler
{
    __block UIImage* cachedImage;
    
    [self.engine getImageFromCacheWithKey:key addCompletionHandler:^(id response) {
        
        if(!response) completionHandler(nil);
        else{
            
            cachedImage = (UIImage*) response;
            
            completionHandler(cachedImage);
        }
        
    }];
    
    
}

// Fetch Persistent Storage Cache for Image
-(void)managerFetchPersistentStorageCachedImageForKey:(NSString *)key deal:(Deal *)aDeal addCompletion:(fetchedImageResponse)completionHandler
{
    __block UIImage* cachedImage = [[UIImage alloc] init];
    
    [self.engine getImageFromCachePersistenceStorageWithKey:key addCompletionHandler:^(id response) {
        
        if(!response){
            completionHandler(nil);
        }
        else{
            
            cachedImage = (UIImage*) response;
            completionHandler(cachedImage);
            
            [self.engine cacheImage:cachedImage forKey:key addCompletionHandler:^(BOOL success) {
                
                if(!success) completionHandler(nil);
                else{
                    
                    [aDeal.imgStateObject recordImageHTTPResponse:nil andRequest:nil hasImage:YES];
                    
                    //completionHandler(cachedImage);
                    
                }
                
            }];
        }
        
    }];
}

// Download Image Manager
-(void)managerStartDownloadImageFromURLString:(NSString *)requestString forDeal:(Deal *)deal addCompletion:(fetchedImageResponse)completionHandler
{
    
    [self.engine downloadImageFromURL:requestString addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        [self.engine cacheImage:imageResponse forKey:deal.imgStateObject.imagePath addCompletionHandler:^(BOOL success) {
            
            if(success){
                
                [deal.imgStateObject recordImageHTTPResponse:response andRequest:request hasImage:YES];

                
                [self.engine saveToCachePersistenceStorageImage:imageResponse forKey:deal.imgStateObject.imagePath addCompletionHandler:^(BOOL success) {
                    
                    completionHandler(imageResponse);
                    
                }];

            }
            
        }];
        
    }];
    
}

-(void)managerStartDownloadImageFromURL:(NSString *)url forObject:(id)object forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView
{
    [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        __block BOOL imgExist = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([object isMemberOfClass:[InstagramObject class]]) {
                
                InstagramObject* obj = (InstagramObject*) object;
                
                [obj.mediaStateHandler recordImageHTTPResponse:response andRequest:request hasImage:imgExist];
                
                [self.delegate imageFetchedForObject:obj forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
                
            }
            else if ([object isMemberOfClass:[DealTableViewCell class]]){
                
                if (imageResponse) {
                    
                    imgExist = YES;
                    
                    Deal* objDeal = self.fetchedDeals[indexPath.row];
                    
                    //Cache the image
                    [self.engine cacheImage:imageResponse forKey:objDeal.imgStateObject.imagePath addCompletionHandler:^(BOOL success) {
                       
                        if(success){
                            
                            [objDeal.imgStateObject recordImageHTTPResponse:response andRequest:request hasImage:imgExist];
                            
                            [self.engine saveToCachePersistenceStorageImage:imageResponse forKey:objDeal.imgStateObject.imagePath addCompletionHandler:^(BOOL success) {
                                
                                [self.delegate imageFetchedForObject:object forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
                                
                            }];
                            
                        }
                        
                    }];
                    
                }
                
            }
        });
        
    }];
}

-(void)managerStartDownloadImageFromURL:(NSString *)url forDeal:(Deal *)deal forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView
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
-(void)managerStartDownloadImageFromURL:(NSString *)url forIndexPath:(NSIndexPath *)indexPath andImageView:(UIImageView *)imgView
{
    
    [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage *imageResponse, NSHTTPURLResponse *response, NSURLRequest *request) {
        
        [self.delegate imageFetchedForObject:nil forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
    }];
}

-(void)managerCancelDownloads:(generalBlockResponse)completionHandler
{
    [self.engine cancelOperations:^(BOOL success) {
        
        completionHandler(YES);
        
    }];
}

-(void)managerSortDeals:(NSArray *)deals byKey:(NSString *)key ascendingOrder:(BOOL)shouldAscend localizeCompare:(BOOL)shouldLocalize addCompletetion:(dataBlockResponse)completionHandler
{
    [self.engine sortArray:deals byKey:key ascending:shouldAscend localizeCompare:shouldLocalize addCompletion:^(id response) {
        
        if(response){
            
            NSArray* sortedArray = (NSArray*) response;
            
            NSLog(@"Sorted Array is %@", sortedArray);
            
            completionHandler(sortedArray);
            
        }
        else completionHandler(nil);
        
    }];
    
}

-(NSArray *)managerCreateMapAnnotationsForDeals:(NSArray *)deals addressInfo:(NSArray*)info
{
    if(!deals || !info) return nil;
    
    return [self.engine createMapAnnotationsForDeals:deals addressInfo:info];
}

-(NSString*)managerGetCurrentDateString
{
    NSString* today = [self.engine currentDateString];
    
    return today;
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

-(void)managerResetDeals
{
    self.fetchedDeals = [[NSArray alloc] init];
    totalLoadedDeals_Count = 0;
    NSLog(@"Deals removed!");
}

#pragma mark -
#pragma mark - Database Engine delegates
-(void)totalDealCountFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    [self.delegate dealsDidNotLoad];
}

-(void)dealsFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    [self.delegate dealsDidNotLoad];
}

-(void)operationsCancelled
{
    NSLog(@"Operations Cancelled");
    
    
}


@end
