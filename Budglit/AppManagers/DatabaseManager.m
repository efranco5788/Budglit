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
#import "Deal.h"
#import "DealParser.h"
#import "InstagramObject.h"

#define HOST_NAME @"https://www.budglit.com"

#define DEFAULT_ATTEMPT_RETRIES 1

#define SQLITE_DB_NAME @"PSOfflineZipcodeDB"

#define KEY_FOR_RETURNED_DEALS @"allDeals"
#define KEY_FOR_TOTAL_COUNT @"totalDeals"
#define KEY_ADDRESS_INFO @"addressInfo"
#define KEY_ADDRESS @"address"
#define KEY_ADDRESS_COMPONENT @"addressComponent"
#define KEY_DEALS @"deals"
#define KEY_DEALS_ID @"dealID"
#define KEY_TIMESTAMP @"timestamp"

static DatabaseManager* sharedManager;


@interface DatabaseManager()<EngineDelegate>
{
    dispatch_queue_t backgroundQueue;
}
@property (nonatomic, strong) NSDictionary* dealsInfo;
//@property (nonatomic, strong) NSArray* fetchedDeals;
@property (nonatomic, strong) NSArray* tmpDeals;
@property (nonatomic, strong) NSDictionary* searchFilter;
@property (nonatomic, strong) NSArray* plottedMapAnnotations;
@property (nonatomic, strong) NSTimer* timerRequest;
@end

@implementation DatabaseManager

+(DatabaseManager *)sharedDatabaseManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[self alloc] initWithEngineHostName:HOST_NAME];
        
    });
    
    return sharedManager;
}

-(instancetype)initWithEngineHostName:(NSString *)hostName
{
    self = [super initWithEngineHostName:hostName];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[DatabaseEngine alloc] initWithHostName:hostName];
    
    (self.engine).delegate = self;
    
    self.dealParser = [[DealParser alloc] initParser];
    
    self.plottedMapAnnotations = [[NSArray alloc] init];
    
    self.dealsInfo = nil;
    
    NSString* sqliteDB = [[NSBundle mainBundle] pathForResource:SQLITE_DB_NAME ofType:@"sqlite3"];
    
    if(sqlite3_open(sqliteDB.UTF8String, &database) != SQLITE_OK){
        NSLog(@"Failed to open database");
    }
    else{
        NSLog(@"database connection SUCCESS.");
    }
    
    return self;
}

#pragma mark -
#pragma mark - Websocket Methods
-(void)managerConstructWebSocket:(NSString *)token addCompletionBlock:(dataBlockResponse)completionHandler
{
    
    if(token){
        
        [self.engine constructWebSocket:token addCompletion:^(id response) {
           
            if(response){
                
                [self.engine setSocketEventsAddCompletion:^(id eventResponse) {
                    completionHandler(eventResponse);
                }];
                
            }
            
        }];
    }
}

-(void)managerDisconnectWebSocket
{
    [super managerDisconnectWebSocket];
    
    [self.engine.socket disconnect];
}

#pragma mark -
#pragma mark - Saved Deals Methods
-(NSArray*)managerGetSavedDeals
{
    if(self.dealsInfo){
        
        NSArray* deals = (NSArray*) [self.dealsInfo valueForKey:KEY_DEALS];
        
        if(deals) return deals;
        else return nil;
        
    }
    else return nil;
}

-(NSDate*)managerGetTimestamp
{
    if(self.dealsInfo){
        
        NSDate* timestamp = (NSDate*) [self.dealsInfo valueForKey:KEY_TIMESTAMP];
        
        if(timestamp) return timestamp;
        else return nil;
        
    }
    else return nil;
    
}

-(BOOL)managerSaveFetchedDeals:(NSArray*)dealsFetched
{
    if(dealsFetched){

        NSDate* timestamp = [NSDate date];
        
        self.dealsInfo = @{KEY_DEALS : dealsFetched,
                           KEY_TIMESTAMP : timestamp
                           };
        
        return YES;
    }
    else return NO;
}

-(BOOL)managerUpdateFetechedDeals:(NSArray *)newDeals
{
    if(newDeals){
        
        NSMutableArray* mutableDeals = [[self managerGetSavedDeals] mutableCopy];
        
        [mutableDeals addObjectsFromArray:newDeals];
        
        return [self managerSaveFetchedDeals:mutableDeals.copy];
        
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

-(NSArray*)managerFilterDeals:(NSArray*)deals byType:(FilterType)type filterCriteria:(double)criteria
{
    if(!deals){
        deals = [self managerGetSavedDeals];
    }
    else if (deals.count == 0){
        return @[];
    }
    
    NSPredicate* dealPredicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", [Deal class]];
    
    NSArray* foundDealsMutable = [deals filteredArrayUsingPredicate:dealPredicate];
    
    if(!foundDealsMutable){
        return nil;
    }
    
    NSArray* filtered;
    
    if(type == FilterTypeBudget) {
        filtered = [self.engine filterOutDeals:foundDealsMutable byBudgetAmount:criteria];
    }
    else {
        filtered = [self.engine filterOutDeals:foundDealsMutable byDistance:criteria];
    }
    
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
-(void)managerFetchDeals:(NSDictionary*)searchCriteria addCompletionBlock:(dataBlockResponse)completionHandler
{
    [self managerFetchDeals:searchCriteria shouldClearCurrentDeals:YES addCompletionBlock:completionHandler];
}

-(void)managerFetchDeals:(NSDictionary *)searchCriteria shouldClearCurrentDeals:(BOOL)shouldClear addCompletionBlock:(dataBlockResponse)completionHandler
{
    searchCriteria = searchCriteria ? searchCriteria : [[self managerGetUsersCurrentCriteria] copy];
    
    [self.engine sendSearchCriteria:searchCriteria addCompletion:^(id response) {
        
        if([response isKindOfClass:[NSDictionary class]]){
            
            NSDictionary* dict = (NSDictionary*) response;
            
            BOOL authenticated = [self.engine extractAuthetication:dict];
            
            if(authenticated == FALSE) [self.delegate managerUserNotAuthenticated];
            else{
                
                NSArray* dealsExtracted = [self.engine extractDeals:dict];
                
                NSArray* parsedDeals = [self.dealParser parseDeals:dealsExtracted];
                
                if(parsedDeals){
                    
                    NSMutableArray* newDealArray = [[NSMutableArray alloc] init];
                    
                    NSArray* deals = [self managerGetSavedDeals];
                    
                    if(deals.count < 1){
                        
                        for (Deal* node in parsedDeals) {
                            [newDealArray addObject:node];
                        }
                        
                        BOOL saved = [self managerSaveFetchedDeals:newDealArray];
                        
                        NSNumber* savedValue = [NSNumber numberWithBool:saved];
                        
                        completionHandler(savedValue);
                        
                        
                    }
                    else{
                        
                        for (Deal* node in parsedDeals) {
                            
                            NSPredicate* dealIDPredicate = [NSPredicate predicateWithFormat:@"SELF.dealID LIKE %@", node.dealID];
                            
                            NSArray* dealFoundArry = [deals filteredArrayUsingPredicate:dealIDPredicate];
                            
                            if(dealFoundArry.count < 1){
                                [newDealArray addObject:node];
                            }
                            
                        }
                        

                        if(shouldClear) [self managerResetDeals];

                        BOOL updated = [self managerUpdateFetechedDeals:newDealArray];
                        
                        NSNumber* updatedValue = [NSNumber numberWithBool:updated];
                        
                        completionHandler(updatedValue);
                        
                    }
                    
                    
                }
                else{
                    
                    NSArray* savedDeals = [self managerGetSavedDeals];
                    
                    if(savedDeals > 0) completionHandler(savedDeals);
                    else{
                        
                        NSNumber* savedValue = [NSNumber numberWithBool:NO];
                        
                        completionHandler(savedValue);
                        
                    }
                    
                }
                
            }
            
        }
        else if ([response isKindOfClass:[NSError class]])
        {
            NSError* error = (NSError*) response;
            
            NSLog(@"%@", error.localizedDescription);
            
            completionHandler(error);
            
        }
        else completionHandler(nil);
        
    }];  //End of search criteria method
            
    
}

-(NSArray*)managerExtractAddressesFromDeals:(NSArray*)deals
{
    if(deals.count < 1) return nil;
    
    NSMutableArray* mutableDeals = deals.mutableCopy;
    
    for (Deal* d in deals) {
        
        NSLog(@"The address is %@", d.standardizeAddress);
        
        if(d.standardizeAddress != nil){
            
            [mutableDeals removeObject:d];
            
            NSLog(@"Removed!!");
            
        }
    }
    
    if(mutableDeals.count < 1) return nil;
    
    NSLog(@"%@", mutableDeals);
    
    return [self.engine extractAddressFromDeals:mutableDeals.copy];
}

-(void)managerContinousRetryRequest:(NSTimer*)timer
{
    if([timer isValid]){
        
        NSDictionary* info = [timer userInfo];
        
        NSString* path = [info valueForKey:@"path"];
        
        [self.engine headRequestToPath:path parameters:nil addCompletion:^(id response) {
            
            if([response isKindOfClass:[NSNumber class]]){
                
                NSNumber* responseData = (NSNumber*) response;
                
                BOOL isOnline = [responseData boolValue];
                
                if(isOnline == YES){
                    [timer invalidate];
                    
                    [self.delegate managerHostBackOnline];
                }
                
            }
            

        }];

    }
    
}

-(void)managerSaveStandardizedAddressesForDeals:(NSArray*)info
{
    if(info){
        
        for (NSDictionary* nodeAry in info) {

            NSArray* dealIDAry = [nodeAry valueForKey:KEY_DEALS_ID];
            
            NSDictionary* dict = [nodeAry valueForKey:KEY_ADDRESS_COMPONENT];
            
            NSString* uniqueID = [dealIDAry firstObject];
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.dealID LIKE %@", uniqueID];
            
            NSArray* savedDeals = [self managerGetSavedDeals];
            
            NSArray* filtered = [savedDeals filteredArrayUsingPredicate:predicate];
            
            if(filtered.count > 0){
                
                NSString* standardAddress = [dict valueForKey:@"formatted_address"];
                
                Deal* d = [filtered firstObject];
                
                [d setStandardizeAddress:standardAddress];
                
                [d setAddressInfo:dict];
                
            }

            
        }
        
    }
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
            
            if (!parse){ completionHandler(response);}
            else{
                
                NSDictionary* unparsedAddress = (NSDictionary*) response;
                
                NSDictionary* parsedAddress = [self.engine parseGeocodeLocation:unparsedAddress];
                
                completionHandler(parsedAddress);
                
            }
            
            
        }
        
    }];
}

-(void)managerFetchGeocodeForAddresses:(NSArray*)addressList additionalParams:(NSDictionary *)params shouldParse:(BOOL)parse addCompletetion:(dataBlockResponse)completionHandler
{
    NSMutableDictionary* tmpMutableParameters = [[NSMutableDictionary alloc] init];
    
    if(addressList){
        
        NSArray* unorderedAddressList = [self.engine removeDuplicateFromArray:addressList Unordered:YES];
        
        NSDictionary* parameters = [self.engine constructParameterWithKey:KEY_ADDRESS_INFO AndValue:unorderedAddressList addToDictionary:params];
        
        tmpMutableParameters = parameters.mutableCopy;

    }
    
    if(params){
        [tmpMutableParameters addEntriesFromDictionary:params];
    }
    
    [self.engine sendAddressesForGeocode:tmpMutableParameters.copy addCompletionHandler:^(id response) {
        
        if(!response) completionHandler(nil);
        else{
            
            if(!parse) completionHandler(response);
            else{
                
                NSArray* addressList = (NSArray*) response;
                
                NSMutableArray* mutableParsedList = [[NSMutableArray alloc] init];
                
                for (NSArray* node in addressList) {

                    NSArray* fullAddressAry = [node firstObject];
                    
                    NSDictionary* addressInfo = [fullAddressAry firstObject];
                    
                    NSDictionary* componentsDict = [addressInfo valueForKey:KEY_ADDRESS_COMPONENT];

                    NSDictionary* parsedAddress = [self.engine parseGeocodeLocation:componentsDict];
                    
                    NSDictionary* dealIDInfo = [fullAddressAry valueForKey:KEY_DEALS_ID];
                    
                    NSDictionary* info = [[NSDictionary alloc] initWithObjects:@[parsedAddress, dealIDInfo] forKeys:@[KEY_ADDRESS_COMPONENT, KEY_DEALS_ID]];
                    
                    [mutableParsedList addObject:info];
                    
                }
                
                completionHandler(mutableParsedList.copy);
                
            }
            
        }
        
        
    }];
}

-(void)managerFetchNewDataWithCompletion:(newDataFetchedResponse)completionHandler
{
    
}

// Fetch Memory Cahce for Image
-(void)managerFetchCachedImageForKey:(NSString *)key addCompletion:(fetchedImageResponse)completionHandler
{
    
    [self.engine getImageFromCacheWithKey:key addCompletionHandler:^(id response) {
        
        if(!response) completionHandler(nil);
        else{
            
            UIImage* cachedImage = (UIImage*) response;
            
            completionHandler(cachedImage);
        }
        
    }];

}

// Fetch Persistent Storage Cache for Image
-(void)managerFetchPersistentStorageCachedImageForKey:(NSString *)key deal:(Deal *)aDeal addCompletion:(fetchedImageResponse)completionHandler
{
    
    [self.engine getImageFromCachePersistenceStorageWithKey:key addCompletionHandler:^(UIImage *response) {
        
        if(!response){
            completionHandler(nil);
        }
        else{
            
            [self.engine cacheImage:response forKey:key addCompletionHandler:^(BOOL success) {
                
                if(!success){
                    completionHandler(nil);
                }
                else{
                    
                    [aDeal.imgStateObject recordImageHTTPResponse:nil andRequest:nil hasImage:YES];
                    
                    completionHandler(response);
                    
                }
                
            }];
            
        }
        
    }];
    
}


#pragma mark -
#pragma mark - Image Download Methods
-(void) managerStartDownloadImageFromURL:(NSString*)url forObject:(id)object forIndexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imgView addCompletion:(fetchedImageResponse)completionHandler
{
    __block BOOL imageExist = NO;
    
    UIImage* defaultImg = [UIImage imageNamed:@"Cell_ImagePlaceholder.jpg"];

    if(!url || url.length < 1){
        
        Deal* deal = (Deal*) object;
        
        [deal.imgStateObject recordImageHTTPResponse:nil andRequest:nil hasImage:NO];
        
        if(completionHandler)completionHandler(defaultImg);
        else{
            [self.delegate imageFetchedForObject:deal forIndexPath:indexPath andImage:defaultImg andImageView:imgView];
        }
        
    }
    else{
        
    
        [self.engine downloadImageFromURL:url forImageView:imgView addCompletionHandler:^(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request) {
            
            NSLog(@"url is %@", url);
            
            NSLog(@"img is %@", imageResponse);
            
            if (imageResponse) imageExist = YES;
            
            if(!object) {
                
                if(completionHandler){
                    completionHandler(defaultImg);
                    
                }
                else{
                    [self.delegate imageFetchedForObject:defaultImg forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
                }
                
                
            }
            else if([object isMemberOfClass:[Deal class]]) {
                
                Deal* deal = (Deal*) object;
                
                if(completionHandler){
                    
                    [deal.imgStateObject recordImageHTTPResponse:nil andRequest:nil hasImage:NO];
                    
                    completionHandler(imageResponse);
                    
                }
                else{
                    
                    [deal.imgStateObject recordImageHTTPResponse:response andRequest:request hasImage:YES];
                    
                    [self.delegate imageFetchedForObject:object forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
                }
                
                
            }
            else if ([object isMemberOfClass:[InstagramObject class]]) {
                
                InstagramObject* obj = (InstagramObject*) object;
                
                if(completionHandler)completionHandler(imageResponse);
                else{
                    
                    [obj.mediaStateHandler recordImageHTTPResponse:response andRequest:request hasImage:imageExist];
                    
                    [self.delegate imageFetchedForObject:obj forIndexPath:indexPath andImage:imageResponse andImageView:imgView];
                    
                }
                
                
            }
            
        }];
        
    }
    
    
    
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

-(NSArray*)managerCreateMapAnnotationsForDeals:(NSArray *)deals
{
    if(!deals || deals.count < 1) return nil;
    
    return [self.engine createMapAnnotationsForDeals:deals];
}

-(NSString*)managerGetCurrentDateString
{
    NSString* today = [self.engine currentDateString];
    
    return today;
}

-(void)managerResetDeals
{
    self.dealsInfo = nil;
    NSLog(@"Deals removed!");
}

-(void)managerClearSearchFilter
{
    [self.engine clearCurrentSearchFilter];
}

#pragma mark -
#pragma mark - Database Engine delegates
-(void)requestFailedWithError:(NSDictionary*)info
{
    [self.delegate managerRequestFailed];
    
    if(!self.timerRequest){
        
         self.timerRequest = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(17.0) target:self selector:@selector(managerContinousRetryRequest:) userInfo:info repeats:YES];
        
        [self.timerRequest fire];
        
    }
    
    
}


@end
