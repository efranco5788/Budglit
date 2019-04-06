//
//  LoadingLocalDealsViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class BudgetManager;
//@class DatabaseManager;
@class Deal;
@class LocationSeviceManager;
@class PSEditZipcodeOfflineTableViewController;

typedef void (^completionBlock)(id results);

@protocol LoadingPageDelegate <NSObject>
@optional
-(void)loadingPageDismissed:(id)object;
-(void)loadingPageErrorFound:(NSError*)error;
-(void)newDealsAvailable;
@end

@interface LoadingLocalDealsViewController : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) id<LoadingPageDelegate> delegate;

@property (nonatomic, strong) PSEditZipcodeOfflineTableViewController* editOfflinePage;

-(void) fetchInitialUserLocationOffline;

-(void) fetchUserLocationOfflineHideBackButton:(BOOL)hide;

-(void) fetchUserLocationOnline;

//-(void) fetchSurroundingZipcodes:(NSString*)zipcode;

-(void) applicationReactivated;

-(void) toggleBackgroundDimmer;

-(void) dismiss;


@end
