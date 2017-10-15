//
//  DrawerViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 5/4/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "DrawerViewController.h"
#import "AppDelegate.h"
#import "LoadingLocalDealsViewController.h"
#import "MenuOptions.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerVisualState.h"
#import "MMDrawerController+Subclass.h"
#import "MenuTableViewController.h"
#import "PSAllDealsTableViewController.h"
#import "UINavigationController+CompletionHandler.h"

#define MAX_DRAWER_WIDTH 0.65
#define LOADING_PAGE_VIEW_CONTROLLER @"LoadingLocalDealsViewController"


@interface DrawerViewController () <MenuViewDelegate, LoadingPageDelegate, AccountManagerDelegate>

@end

@implementation DrawerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    LoadingLocalDealsViewController* LLLDVC = [[LoadingLocalDealsViewController alloc] initWithNibName:LOADING_PAGE_VIEW_CONTROLLER bundle:nil];
    
    self.loadingPage = LLLDVC;
    
    (self.view).backgroundColor = [UIColor whiteColor];

    [self setShowsShadow:YES];
    
    CGFloat viewWidth = self.view.frame.size.width;
    
    CGFloat drawerWidth = viewWidth * MAX_DRAWER_WIDTH;
    
    self.maximumRightDrawerWidth = drawerWidth;
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    [self
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         UIViewController * sideDrawerViewController;
         if(drawerSide == MMDrawerSideLeft){
             sideDrawerViewController = drawerController.leftDrawerViewController;
         }
         else if(drawerSide == MMDrawerSideRight){
             sideDrawerViewController = drawerController.rightDrawerViewController;
         }
         (sideDrawerViewController.view).alpha = percentVisible;
     }];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* currentLocation = [NSString stringWithString:[appDelegate.locationManager retrieveCurrentLocation]];
    
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
    
    UIBarButtonItem* locationBtn = [[UIBarButtonItem alloc] initWithTitle:currentLocation style:UIBarButtonItemStylePlain target:self action:nil];
    
    [self.navigationItem setLeftBarButtonItem:locationBtn animated:NO];
    
    MenuTableViewController* menu = (MenuTableViewController*) self.rightDrawerViewController;
    
    menu.delegate = self;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    MenuTableViewController* menu = (MenuTableViewController*) self.rightDrawerViewController;
    
    [menu setDelegate:nil];
}

-(void)rightDrawerButtonPress:(id)sender
{
    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

-(void)configureCenterViewController:(UIViewController *)centerViewController leftDrawerViewController:(UIViewController *)leftDrawerViewController rightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    [super configureCenterViewController:centerViewController leftDrawerViewController:leftDrawerViewController rightDrawerViewController:rightDrawerViewController];
    
    if (centerViewController) {
        self.centerViewController = centerViewController;
    }
    
    if (rightDrawerViewController) {
        self.rightPanelMenuView = (MenuTableViewController*)rightDrawerViewController;
    }
    
    if (leftDrawerViewController) {
        self.leftDrawerViewController = (MenuTableViewController*)leftDrawerViewController;
    }
}


#pragma mark -
#pragma mark - Right Panel Menu Delegate
-(void)menuSelected:(NSInteger)menuOption
{
    [self closeDrawerAnimated:YES completion:^(BOOL finished) {
        
        if (finished)
        {
            switch (menuOption) {
                case menuCurrentLocation:
                {
                    if (![CLLocationManager locationServicesEnabled]) {
                        NSString* alertMessage = @"Please turn on your Location Services. Settings > Privacy > Location Services";
                        UIAlertController* locationsNotification = [UIAlertController alertControllerWithTitle:@"" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [locationsNotification addAction:defaultAction];
                        [self presentViewController:locationsNotification animated:YES completion:nil];
                    }
                    else [self changeCurrentLocation];
                }
                    break;
                case menuChangeLocation:
                {
                    [self changeLocation];
                }
                    break;
                case menuChangeBudget:
                {
                    [self changeBudget];
                }
                    break;
                case menuLogout:
                {
                    [self logout];
                }
                    break;
                default:
                    break;
            }
        }
        
        
    }];
}

#pragma mark -
#pragma mark - Controller Methods
-(void)changeCurrentLocation
{
    [self.navigationController completionhandler_pushViewController:self.loadingPage withController:self.navigationController animated:NO completion:^{
        
        (self.loadingPage).delegate = self;
        
        [self.loadingPage fetchUserLocationOnline];
        
    }];
    
}

-(void)changeLocation
{
    UIModalTransitionStyle style = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController completionhandler_pushViewController:self.loadingPage withController:self.navigationController withTransition:&style animated:NO completion:^{
        
        (self.loadingPage).delegate = self;
        
        [self.loadingPage fetchUserLocationOfflineHideBackButton:NO];
    }];
}

-(void)changeBudget
{
    [self.navigationController completionhandler_pushViewController:self.loadingPage withController:self.navigationController animated:NO completion:^{
        
        (self.loadingPage).delegate = self;
       
        [self.loadingPage inputBudget];
        
    }];
}

-(void)logout
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.accountManager).delegate = self;
    
    [appDelegate.accountManager logout];
}

#pragma mark -
#pragma mark - Loading Page Delegate
-(void)newDealsFetched
{
    PSAllDealsTableViewController* view = (PSAllDealsTableViewController*) self.centerViewController;

    [self.navigationController completionhandler_popToViewController:self withController:self.navigationController animated:NO completion:^{
        
        [self.loadingPage setDelegate:nil];
        
        [view refreshDeals];
        
    }];
}

-(void)loadingPageDismissed
{
    [self.navigationController completionhandler_popToViewController:self withController:self.navigationController animated:NO completion:^{
        
        [self.loadingPage setDelegate:nil];
        
    }];
}

-(void)budgetHasFinished
{
     PSAllDealsTableViewController* view = (PSAllDealsTableViewController*) self.centerViewController;
    
    [self.navigationController completionhandler_popToViewController:self withController:self.navigationController animated:NO completion:^{
   
        [self.loadingPage setDelegate:nil];
        
        [view refreshDeals];
        
    }];
}

#pragma mark -
#pragma mark - Account Manager Delegate
-(void)logoutSucessfully
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.accountManager setDelegate:nil];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - Memory Handling Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
