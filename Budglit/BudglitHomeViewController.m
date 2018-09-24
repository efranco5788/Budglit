//
//  BudglitHomeViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "BudglitHomeViewController.h"
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
#import "MapViewController.h"

#define PUSH_TO_MAIN_CONTAINER_VIEW @"pushToMainContainer"
#define PUSH_TO_DRAWER_CONTROLLER @"pushToDrawerController"

@interface BudglitHomeViewController () <LoginPageDelegate, LoadingPageDelegate>

@end

@implementation BudglitHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    __block BudglitHomeViewController* blocksafeSelf = self;
    
    [appDelegate.accountManager validateSessionForDomain:@"www.budglit.com" addCompletion:^(id object) {
        
        NSLog(@"%@", object);
        
        if(object == nil || object == NULL) [blocksafeSelf launchLoginPage];
        else if ([object isKindOfClass:[NSError class]]){
            
        }
        else{
            
            NSDictionary* validInfo = (NSDictionary*) object;
            
            id validationValue = [appDelegate.accountManager getValidationValue:validInfo];
            
            BOOL isValid = [validationValue integerValue];
            
            if(isValid == NO){
                
                [appDelegate.accountManager logoutFromDomain:@"www.budglit.com" addCompletion:^(id logoutInfo) {
                    
                    if(logoutInfo) {
                        
                        BOOL loggedOffSuccess = [appDelegate.accountManager checkLoggedOut:object];
                        
                        if(loggedOffSuccess == YES) {
                            [blocksafeSelf launchLoginPage];
                        }
                    }
                    
                    
                }];
                
            }
            else{
                
                UserAccount* user = [appDelegate.accountManager managerSignedAccount];
                
                NSString* userID = [user getUserID];

                [appDelegate.databaseManager managerConstructWebSocket:userID addCompletionBlock:^(id response) {
                    
                    NSLog(@"%@", response);
                    
                    [blocksafeSelf launchLoadingPage];
                    
                }];
                
            }
            
        }
        
    }];
    
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
        
        if (![CLLocationManager locationServicesEnabled]) {
            [self.loadingPage fetchUserLocationOfflineHideBackButton:YES];
        }
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
        
        if ([viewID isEqualToString:@"PSAllDealsTableViewController"]) return YES;
        
    }
    
    return NO;
}

-(IBAction)returned:(UIStoryboardSegue*)segue
{
    NSLog(@"Returned sucessfully");
}


#pragma mark -
#pragma mark - Loading Page Delegate
-(void)loadingPageDismissed:(id)object
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
        [self destroyLoadingPage];
    }];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if(![self.navigationController.topViewController isKindOfClass:[DrawerViewController class]]) {
        
        [self.navigationController pushViewController:appDelegate.drawerController animated:NO];
        
    }

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
