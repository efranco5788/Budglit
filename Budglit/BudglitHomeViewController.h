//
//  BudglitHomeViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BudgetManager;
@class DrawerViewController;
@class LoadingLocalDealsViewController;
@class LoginPageViewController;
@class LocationSeviceManager;
@class UserAccount;

#define HAS_LAUNCHED_ONCE @"HasLaunchedOnce"
#define BUDGET_TITLE @"Budget"

@interface BudglitHomeViewController : UIViewController< UIViewControllerTransitioningDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoginPageViewController* loginPage;

@property (nonatomic, strong) LoadingLocalDealsViewController* loadingPage;

-(IBAction)returned:(UIStoryboardSegue*)segue;

-(void) destroyLoginPage;

-(void) destroyLoadingPage;


@end
