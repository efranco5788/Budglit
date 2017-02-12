//
//  PSAllDealsTableViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSDealDetailViewController;
@class LoadingLocalDealsViewController;
@class AppDelegate;
@class AccountManager;
@class BudgetManager;
@class DatabaseManager;
@class LocationSeviceManager;
@class DrawerViewController;
@class DealTableViewCell;
@class Deal;
@class PSEditZipcodeOfflineTableViewController;


@protocol PSAllDealsTableViewControllerDelegate <NSObject>
@optional
-(void) dealsLoaded;
-(void) imageLoaded:(UIImage*)img;
@end

@interface PSAllDealsTableViewController : UITableViewController

@property (nonatomic, strong) id <PSAllDealsTableViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *dealsTableView;

@property (nonatomic, strong) LoadingLocalDealsViewController* loadingPage;

@property (nonatomic, strong) UIView* backgroundDimmer;

@property (nonatomic, strong) UIBarButtonItem* menuButton;

@property (nonatomic, strong) UIBarButtonItem* budgetButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* btmNavBarLayout;

-(IBAction)returned:(UIStoryboardSegue*)segue;

-(void)refreshDeals;

@end
