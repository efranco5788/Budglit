//
//  PSHomeViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSHomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "DrawerViewController.h"
#import "LoadingLocalDealsViewController.h"
#import "LocationServiceManager.h"
#import "LoginPageViewController.h"
#import "BudgetManager.h"
#import "DatabaseManager.h"
#import "UserAccount.h"
#import "UINavigationController+CompletionHandler.h"


#define PUSH_TO_MAIN_CONTAINER_VIEW @"pushToMainContainer"
#define PUSH_TO_DRAWER_CONTROLLER @"pushToDrawerController"

@interface PSHomeViewController () <LoginPageDelegate, LoadingPageDelegate>

@end

@implementation PSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidAppear:(BOOL)animated
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    UserAccount* user = appDelegate.accountManager.getSignedAccount;
    
    NSString* budgetValue = [defaults valueForKey:NSLocalizedString(@"BUDGET", nil)];

    if (!user) {
        [self launchLoginPage];
    }
    else if ([user.firstName isEqualToString:NSLocalizedString(@"DEFAULT_NO_ACCOUNT_NAME", nil)])
    {
        [self launchLoginPage];
    }
    else
    {
        [appDelegate.accountManager sessionValidator];
        //[self launchLoadingPage];
    }
    
    user = nil;
    budgetValue = nil;
    defaults = nil;
}

-(void)launchLoginPage
{
    if (self.loginPage == nil) {
        
        self.loginPage = [[LoginPageViewController alloc] initWithNibName:@"LoginPageViewController" bundle:nil];
        
        (self.loginPage).delegate = self;
        
        (self.loginPage).modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self presentViewController:self.loginPage animated:NO completion:nil];
}

-(void)destroyLoginPage
{
    self.loginPage.delegate = nil;
    self.loginPage = nil;
}

-(void)launchLoadingPage
{
    if (!self.loadingPage) {
        
        self.loadingPage = [[LoadingLocalDealsViewController alloc] initWithNibName:@"LoadingLocalDealsViewController" bundle:nil];
    }
    
    self.loadingPage.delegate = self;
    
    [self.navigationController completionhandler_pushViewController:self.loadingPage withController:self.navigationController animated:NO completion:^{

        if (![CLLocationManager locationServicesEnabled]) [self.loadingPage fetchUserLocationOfflineHideBackButton:YES];
        else [self.loadingPage fetchUserLocationOnline];
        
    }];
    
}

-(void)destroyLoadingPage
{
    self.loadingPage.delegate = nil;
}

#pragma mark -
#pragma mark - Application Delegates
-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

-(void)applicationFinishedRestoringState
{
    
}

#pragma mark -
#pragma mark - Navigation Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

// Method needed to indicate view controller can accept unwind actions
-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    if ([self respondsToSelector:action]) {
        
        NSString* viewID = fromViewController.restorationIdentifier;
        
        if ([viewID isEqualToString:@"PSAllDealsTableViewController"]) {
            return YES;
        }
    }
    
    return NO;
}

-(IBAction)returned:(UIStoryboardSegue*)segue
{
    NSLog(@"Returned sucessfully");
}


#pragma mark -
#pragma mark - Loading Page Delegate
-(void)loadingPageDismissed
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
        [self destroyLoadingPage];
    }];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if(![self.navigationController.topViewController isKindOfClass:[DrawerViewController class]]) {
        
        [self.navigationController pushViewController:appDelegate.drawerController animated:NO];
    }

}

-(void)locationHasFinished
{
    [self.loadingPage inputBudget];
}

-(void)budgetHasFinished
{
    [self.loadingPage reloadDeals];
}

-(void)newDealsFetched
{
    [self loadingPageDismissed];
}

#pragma mark -
#pragma mark - Login Page Delegate
-(void)loginSucessful
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self destroyLoginPage];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
