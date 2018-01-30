//
//  AppDelegate.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import "TwitterKit/TwitterKit.h"
#import "PSAllDealsTableViewController.h"
#import "BudgetPickerViewController.h"
#import "MapViewController.h"
#import "MenuTableViewController.h"
#import "UserAccount.h"

//#define GN_API_URL @"http://api.geonames.org"
//#define GN_API_URL @"https://budglit.com"
#define HOST_NAME @"https://www.budglit.com"
#define TWITTER_HOST_NAME @"https://api.twitter.com"
#define INSTAGRAM_HOST_NAME @"https://api.instagram.com"
#define IMAGE_CACHE_NAME @"imageCache"
#define X_USER_AGENT_HEADER @"X-User-Agent"
#define GN_API_PARAM_USERNAME @"efranco5788"
#define TWITTER_CONSUMER_KEY @"vvB776xHclCYeuvqtyQaNeMzc"
#define TWITTER_CONSUMER_SECRET @"UwnK75h6fSJHmNUJdtDQgnTWWr2EbIoCjfBbKH5fwd7BgFx3MF"
#define INSTAGRAM_CLIENT_ID @"f14e6defc65e4a2abd9ac34130b8dda0"
#define INSTAGRAM_CLIENT_SECRET @"48d0454056ce4a4781b2219b6df4591e"
#define GOOGLE_MAPS_API @"AIzaSyB60WbADxLhP0izZL3upDdiUczawDylfvM"

#define K_ROOT_CONTROLLER_KEY @"kRootViewControllerKey"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    
    // Verify the users locale
    NSLocale* usersLocale = [NSLocale autoupdatingCurrentLocale];
    
    if ([usersLocale.localeIdentifier isEqualToString:NSLocalizedString(@"USA", nil)]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self construct_AccountManager];
            [self construct_DatabaseManager];
            [self construct_LocationServiceManager];
            [self construct_BudgetManager];
            [self construct_FacebookManager];
            [self construct_imageDocumentCache];
            [self construct_TwitterEngine];
            [self construct_InstagramManager];
            [self construct_DrawerController];
            
        });
        
        [self.budgetManager resetBudget];
        
        /*******TESTING OUT LOGGING OUT SYSTEM******/
        //[self.accountManager logout];
        
        NSString* sessionID = [self.accountManager getSessionID];
        
        NSDictionary* appDefaults;
        
        NSLog(@"Session ID %@", sessionID);
        
        // If Session ID does not exists
        if (!sessionID){
            
            appDefaults = [self constructDefaultObjects];
            
            NSDictionary* userAcnt = [self constructDefaultUserAccount];
            
            NSMutableDictionary* appendDicts = [[NSMutableDictionary alloc] initWithDictionary:appDefaults];
            
            [appendDicts addEntriesFromDictionary:userAcnt];
            
            NSDictionary* finalDefaults = appendDicts.copy;
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:finalDefaults];
        }
        else{
            
            UserAccount* loggedAcount = [self.accountManager getSignedAccount];
            
            if (!loggedAcount) {
                // Session ID exists but no User Account
                [self.accountManager clearSessionInfo];
                
                appDefaults = [self constructDefaultObjects];
                
                NSDictionary* userAcnt = [self constructDefaultUserAccount];
                
                NSMutableDictionary* appendDicts = [[NSMutableDictionary alloc] initWithDictionary:appDefaults];
                
                [appendDicts addEntriesFromDictionary:userAcnt];
                
                NSDictionary* finalDefaults = appDefaults.copy;
                
                [[NSUserDefaults standardUserDefaults] registerDefaults:finalDefaults];
            }
            else{
                
                appDefaults = [self constructDefaultObjects];
                
                [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
                
            }
            
        }
        
        return YES;
    }
    else return NO;
}

/*
To post-process the results from actions that require you to switch to the native Facebook app or Safari, such as Facebook Login or Facebook Dialogs
*/
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];

    return handled;
    
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.databaseManager) {
        [self.databaseManager fetchNewDataWithCompletion:^(UIBackgroundFetchResult result) {
            completionHandler(result);
        }];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults synchronize];
    
    NSLog(@"Default information saved. App will enter background.");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self.imageDataCache removeAllObjects];
    [self saveContext];
    [self.databaseManager.engine clearCurrentSearchFilter];
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

-(void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.window.rootViewController forKey:K_ROOT_CONTROLLER_KEY];
}

-(void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    UINavigationController *navControlller = [coder decodeObjectForKey:K_ROOT_CONTROLLER_KEY];
    
    if (navControlller) {
        self.window.rootViewController = navControlller;
    }
}

-(NSDictionary *)constructDefaultUserAccount
{
    UserAccount* loggedAccount = [[UserAccount alloc] initWithFirstName:NSLocalizedString(@"DEFAULT_NO_ACCOUNT_NAME", nil) andLastName:nil];
    
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:loggedAccount];
    
    NSArray* defaultObjects = @[accountData];
    
    NSArray* defaultKeys = @[ NSLocalizedString(@"ACCOUNT", nil)];
    
    NSDictionary* userAccountDefault = [NSDictionary dictionaryWithObjects:defaultObjects forKeys:defaultKeys];
    
    return userAccountDefault;
}

-(NSDictionary*)constructDefaultObjects
{
    NSNumber* launched = @NO;
    
    NSMutableDictionary* currentSearchFilters = [[NSMutableDictionary alloc] init];
    
    NSArray* defaultObjects = @[launched, NSLocalizedString(@"DEFAULT_ZIPCODE", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString (@"DEFAULT_BUDGET", nil), currentSearchFilters];
    
    NSArray* defaultKeys = @[NSLocalizedString(@"HAS_LAUNCHED_ONCE", nil), NSLocalizedString(@"ZIPCODE", nil), NSLocalizedString(@"CITY", nil), NSLocalizedString(@"STATE", nil), NSLocalizedString(@"ABBRVIATION", nil), NSLocalizedString(@"BUDGET", nil), NSLocalizedString(@"CURRENT_SEARCH_FILTERS", nil)];
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjects:defaultObjects forKeys:defaultKeys];
    
    return appDefaults;
}

/*
-(NSDictionary *)constructDefaultObjects:(UserAccount *)account
{
    NSNumber* launched = @NO;
    
    NSMutableDictionary* currentSearchFilters = [[NSMutableDictionary alloc] init];
    
    UserAccount* loggedAccount;
    
    if (!account) loggedAccount = [[UserAccount alloc] initWithFirstName:NSLocalizedString(@"DEFAULT_NO_ACCOUNT_NAME", nil) andLastName:nil];
    else [loggedAccount isEqual:account];
    
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:loggedAccount];
    
    NSArray* defaultObjects = @[launched, NSLocalizedString(@"DEFAULT_ZIPCODE", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString(@"DEFAULT", nil), NSLocalizedString (@"DEFAULT_BUDGET", nil), accountData, currentSearchFilters];
    
    NSArray* defaultKeys = @[NSLocalizedString(@"HAS_LAUNCHED_ONCE", nil), NSLocalizedString(@"ZIPCODE", nil), NSLocalizedString(@"CITY", nil), NSLocalizedString(@"STATE", nil), NSLocalizedString(@"ABBRVIATION", nil), NSLocalizedString(@"BUDGET", nil),  NSLocalizedString(@"ACCOUNT", nil), NSLocalizedString(@"CURRENT_SEARCH_FILTERS", nil)];
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjects:defaultObjects forKeys:defaultKeys];
    
    return appDefaults;
}
*/
#pragma mark -
#pragma mark - Manager Initializers
-(void)construct_TwitterEngine
{
    NSDictionary* twitterKeys = @{NSLocalizedString(@"TWITTER_CONSUMER_KEY", nil): TWITTER_CONSUMER_KEY, NSLocalizedString(@"TWITTER_CONSUMER_SECRET_KEY", nil): TWITTER_CONSUMER_SECRET};
    
    self.twitterManager = [[TwitterManager alloc] initWithEngineHostName:TWITTER_HOST_NAME andTwitterKeys:twitterKeys];
    
}

-(void)construct_AccountManager
{
    self.accountManager = [[AccountManager alloc] initWithEngineHostName:HOST_NAME];
}

-(void)construct_BudgetManager
{
    self.budgetManager = [[BudgetManager alloc] init];
}

-(void)construct_DatabaseManager
{
    self.databaseManager = [[DatabaseManager alloc] initWithEngineHostName:HOST_NAME];
}

-(void)construct_FacebookManager
{
    self.fbManager = [[FacebookManager alloc] initWithEngine];
}

-(void)construct_InstagramManager
{
    self.instagramManager = [[InstagramManager alloc] initWithEngineHostName:INSTAGRAM_HOST_NAME andClientID:INSTAGRAM_CLIENT_ID andClientSecret:INSTAGRAM_CLIENT_SECRET];
}

-(void)construct_LocationServiceManager
{
    self.locationManager = [[LocationSeviceManager alloc] initWithEngineHostName:HOST_NAME];
}

-(void)construct_DrawerController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DrawerViewController* drawer = [storyboard instantiateViewControllerWithIdentifier:NSLocalizedString(@"MENU_DRAWER_CONTROLLER", nil)];
    
    MapViewController* centerView = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    MenuTableViewController* rigthPanel = [[MenuTableViewController alloc] init];
    
    BudgetPickerViewController* filterPanel = [[BudgetPickerViewController alloc] init];
    
    [drawer configureCenterViewController:centerView leftDrawerViewController:filterPanel rightDrawerViewController:rigthPanel];
    
    [drawer setShowsShadow:YES];
    
    self.drawerController = drawer;
}

-(void)construct_imageDocumentCache
{
    self.imageDataCache = [[ImageDataCache alloc] init];
    
    [self.imageDataCache setName:IMAGE_CACHE_NAME];
}


#pragma mark -
#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "pocketstretch.net.PocketStretch" in the application's documents directory.
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PocketStretch" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PocketStretch.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    return _managedObjectContext;
}

#pragma mark -
#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

@end
