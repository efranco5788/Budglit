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

@protocol DrawerControllerDelegate <NSObject>
@optional
-(void) switchViewPressed;
@end

@interface DrawerViewController : MMDrawerController

@property (nonatomic, strong) id <DrawerControllerDelegate> delegate;

@property (nonatomic, strong) MenuTableViewController* rightPanelMenuView;

@property (nonatomic, strong) MenuTableViewController* leftPanelMenuView;

@property (nonatomic, strong) LoadingLocalDealsViewController* loadingPage;

-(void)slideDrawerSide:(MMDrawerSide*)drawerSide Animated:(BOOL)isAnimated;

@end
