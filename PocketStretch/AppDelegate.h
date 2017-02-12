//
//  AppDelegate.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DatabaseEngine.h"
#import "BudgetManager.h"
#import "DatabaseManager.h"
#import "AccountManager.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "InstagramManager.h"
#import "LocationServiceManager.h"
#import "ImageDataDoc.h"
#import "DrawerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) DrawerViewController* drawerController;
@property (nonatomic, strong) AccountManager* accountManager;
@property (nonatomic, strong) BudgetManager* budgetManager;
@property (nonatomic, strong) DatabaseManager* databaseManager;
@property (nonatomic, strong) FacebookManager* fbManager;
@property (nonatomic, strong) InstagramManager* instagramManager;
@property (nonatomic, strong) LocationSeviceManager* locationManager;
@property (nonatomic, strong) TwitterManager* twitterManager;
@property (nonatomic, strong) ImageDataDoc* imageDataDocManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

