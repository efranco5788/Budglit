//
//  DrawerViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 5/4/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "MMDrawerController.h"

@class MenuTableViewController;
@class MMDrawerVisualState;
@class LoadingLocalDealsViewController;

@interface DrawerViewController : MMDrawerController

@property (nonatomic, strong) MenuTableViewController* rightPanelMenuView;

@property (nonatomic, strong) MenuTableViewController* leftPanelMenuView;

@property (nonatomic, strong) LoadingLocalDealsViewController* loadingPage;

@end
