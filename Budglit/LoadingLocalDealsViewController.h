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

typedef void (^completionBlock)(id results);

@protocol LoadingPageDelegate <NSObject>
@optional
-(void)loadingPageDismissed:(id)object;
#warning deprecating method
-(void)loadingPageBudgetHasFinished;
-(void)loadingPageErrorFound:(NSError*)error;
-(void)newDealsAvailable;
@end

@interface LoadingLocalDealsViewController : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) id<LoadingPageDelegate> delegate;

@property (nonatomic, strong) PSEditZipcodeOfflineTableViewController* editOfflinePage;

@property (nonatomic, strong) BudgetPickerViewController* budgetPickerView;

-(void) fetchInitialUserLocationOffline;

-(void) fetchUserLocationOfflineHideBackButton:(BOOL)hide;

-(void) fetchUserLocationOnline;

//-(void) fetchSurroundingZipcodes:(NSString*)zipcode;

-(void) applicationReactivated;

-(void) inputBudget;

-(void) toggleBackgroundDimmer;

-(void) dismiss;


@end
