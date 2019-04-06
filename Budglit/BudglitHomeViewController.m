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

#define DOMAIN_NAME @"www.budglit.com"
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
    
    [self.navigationController setNavigationBarHidden:NO];
    
    AccountManager* accountManager = [AccountManager sharedAccountManager];
    
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    __block BudglitHomeViewController* blocksafeSelf = self;
    
    [accountManager validateSessionForDomain:DOMAIN_NAME addCompletion:^(id object) {
        
        NSLog(@"%@", object);
        
        if(object == nil || object == NULL)
        {
            [blocksafeSelf launchLoginPage];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* validInfo = (NSDictionary*) object;
            
            id validationValue = [accountManager getValidationValue:validInfo];
            
            BOOL isValid = [validationValue integerValue];
            
            if(isValid == NO){
                
                [accountManager logoutFromDomain:DOMAIN_NAME addCompletion:^(id logoutInfo) {
                    
                    if(logoutInfo) {
                        
                        BOOL loggedOffSuccess = [accountManager checkLoggedOut:object];
                        
                        if(loggedOffSuccess == YES) {
                            [blocksafeSelf launchLoginPage];
                        }
                    }
                    
                    
                }];
                
            }
            else{
                
                UserAccount* user = [accountManager managerSignedAccount];
                
                if(!user) [blocksafeSelf launchLoginPage];
                else{
                    
                    NSString* userID = [user getUserID];
                    
                    [databaseManager managerConstructWebSocket:userID addCompletionBlock:^(id response) {
                        
                        NSLog(@"%@", response);
                        
                        [blocksafeSelf launchLoadingPage];
                        
                    }];
                    
                }
                
            }
        }
        else if ([object isKindOfClass:[NSError class]])
        {
            
        }
        else{
            
            
        }
        
    }];
    
}

-(void)launchLoginPage
{
    
    if(!self.loginPage){
        self.loginPage = [[LoginPageViewController alloc] initWithNibName:@"LoginPageViewController" bundle:nil];
    }
    
    //(self.loginPage).modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.loginPage.delegate = self;
    
    //[self presentViewController:self.loginPage animated:NO completion:nil];
    
    
    [self.navigationController completionhandler_pushViewController:self.loginPage withController:self.navigationController animated:NO completion:^{
        
        NSLog(@"Delegate is %@", self.loginPage.delegate);
        
        [self.navigationController setNavigationBarHidden:YES];
        
    }];
    
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

-(void)destroyLoginPage
{
    
    [self.navigationController completionhandler_popViewController:self.loginPage withController:self.navigationController animated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:
         NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil userInfo:nil];
        
        self.loginPage.delegate = nil;
        
    }];
    
}

-(void)destroyLoadingPage
{
    [self.navigationController completionhandler_popViewController:self.loadingPage withController:self.navigationController animated:NO completion:^{
        
        self.loadingPage.delegate = nil;
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        if(![self.navigationController.topViewController isKindOfClass:[DrawerViewController class]]) {
            
            [self.navigationController pushViewController:appDelegate.drawerController animated:NO];
            
        }
    }];
}

#pragma mark -
#pragma mark - Frame Methods
-(void)adjustFrameForView:(UIView*)subview
{
    if (@available(iOS 11, *)) {
        
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        
        [subview.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
        [subview.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
        [subview.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [subview.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
        
    } else {
        
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        
        [subview.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
        [subview.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
        [subview.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [subview.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
    }
        
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
    [self destroyLoadingPage];
}

#pragma mark -
#pragma mark - Login Page Delegate
-(void)loginSucessful
{
    [self destroyLoginPage];
}


#pragma mark -
#pragma mark - Memory Managment
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
