//
//  LoadingLocalDealsViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BudgetPickerViewController;
@class BudgetManager;
@class DatabaseManager;
@class Deal;
@class LocationSeviceManager;
@class PSEditZipcodeOfflineTableViewController;
@class PSTransitionToBudgetViewController;

@protocol LoadingPageDelegate <NSObject>
@optional
-(void)loadingPageDismissed;
-(void)locationHasFinished;
-(void)budgetHasFinished;
-(void)newDealsFetched;
@end

@interface LoadingLocalDealsViewController : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) id<LoadingPageDelegate> delegate;

@property (nonatomic, strong) PSEditZipcodeOfflineTableViewController* editOfflinePage;

@property (nonatomic, strong) BudgetPickerViewController* budgetPickerView;

-(void) fetchInitialUserLocationOffline;

-(void) fetchUserLocationOfflineHideBackButton:(BOOL)hide;

-(void) fetchUserLocationOnline;

-(void) applicationReactivated;

-(void) verifyBudget;

-(void) inputBudget;

-(void) reloadDeals;

-(void) toggleBackgroundDimmer;

-(void) dismiss;


@end