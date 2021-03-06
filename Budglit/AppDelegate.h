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
#import "ImageDataCache.h"
#import "DrawerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) DrawerViewController* drawerController;
@property (nonatomic, strong) FacebookManager* fbManager;
@property (nonatomic, strong) TwitterManager* twitterManager;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) saveContext;

-(UIColor*)getPrimaryColor;


@end

