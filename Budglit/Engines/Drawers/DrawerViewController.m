//
//  DrawerViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 5/4/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "DrawerViewController.h"
#import "AppDelegate.h"
#import "AccountMenuTableViewController.h"
#import "LoadingLocalDealsViewController.h"
#import "MapViewController.h"
#import "MenuOptions.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerVisualState.h"
#import "MMDrawerController+Subclass.h"
#import "MenuTableViewController.h"
#import "PSAllDealsTableViewController.h"
#import "UINavigationController+CompletionHandler.h"

#define MAX_RIGHT_DRAWER_WIDTH 0.65
#define MAX_LEFT_DRAWER_WIDTH 0.80
#define LOADING_PAGE_VIEW_CONTROLLER @"LoadingLocalDealsViewController"
#define MAP_VIEW @"MapView"
#define DEALS_TABLE_VIEW @"DealsTableView"
#define ALL_DEALS_TABLE_VIEW @"PSAllDealsTableViewController"
#define FILTER_VIEW @"FilterView"


@interface DrawerViewController () <MenuViewDelegate, LoadingPageDelegate, AccountManagerDelegate, UIGestureRecognizerDelegate>

@end

@implementation DrawerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    LoadingLocalDealsViewController* LLLDVC = [[LoadingLocalDealsViewController alloc] initWithNibName:LOADING_PAGE_VIEW_CONTROLLER bundle:nil];
    
    self.loadingPage = LLLDVC;
    
    (self.view).backgroundColor = [UIColor whiteColor];
    
    CGFloat viewWidth = self.view.frame.size.width;
    
    CGFloat rightDrawerWidth = viewWidth * MAX_RIGHT_DRAWER_WIDTH;
    CGFloat leftDrawerWidth = viewWidth * MAX_LEFT_DRAWER_WIDTH;
    
    self.maximumRightDrawerWidth = rightDrawerWidth;
    self.maximumLeftDrawerWidth = leftDrawerWidth;
    
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.closeDrawerGestureModeMask = MMCloseDrawerGestureModePanningCenterView;
    
    
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

    LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
    
    NSString* currentLocation = [NSString stringWithString:[locationManager retrieveCurrentLocationString]];
    
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

#pragma mark -
#pragma mark - Drawers Panel Gesture Methods
-(void)slideDrawerSide:(MMDrawerSide)drawerSide Animated:(BOOL)isAnimated
{
    [self toggleDrawerSide:drawerSide animated:isAnimated completion:nil];
}

-(void)leftDrawerButtonPress:(id)sender
{
    [self slideDrawerSide:MMDrawerSideLeft Animated:YES];
}

-(void)rightDrawerButtonPress:(id)sender
{
    [self slideDrawerSide:MMDrawerSideRight Animated:YES];
}

-(void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    UIView* accountMenuView = (UIView*) [self.view viewWithTag:101];
    
    if(accountMenuView.superview != nil)
    {
        [accountMenuView removeFromSuperview];
    }
    
    [super closeDrawerAnimated:animated completion:completion];

}


#pragma mark -
#pragma mark - Configure Methods
-(void)configureCenterViewController:(UIViewController *)centerViewController leftDrawerViewController:(UIViewController *)leftDrawerViewController rightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    [super configureCenterViewController:centerViewController leftDrawerViewController:leftDrawerViewController rightDrawerViewController:rightDrawerViewController];
    
    if (centerViewController) {
        self.centerViewController = centerViewController;
    }
    
    if (rightDrawerViewController) {
        self.rightPanelMenuView = rightDrawerViewController;
    }
    
    if (leftDrawerViewController) {
        self.leftDrawerViewController = leftDrawerViewController;
    }
}


#pragma mark -
#pragma mark - Right Panel Menu Delegate
-(void)menuSelected:(NSInteger)menuOption
{
    NSLog(@"%ld", (long)menuOption);
    
    if(menuOption == MENUACCOUNT)
    {
        if([self.rightPanelMenuView isKindOfClass:[MenuTableViewController class]])
        {
            [(MenuTableViewController*) self.rightPanelMenuView presentAccountMenuTable];
        }
        
    }
    else{
        
        [self closeDrawerAnimated:YES completion:^(BOOL finished) {
            
            if (finished)
            {
                switch (menuOption) {
                    case MENUSWITCHMODE:
                    {
                        [self.delegate switchViewPressed];
                    }
                        break;
                    case MENUCURRENTLOCATION:
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
                    case MENUCHANGELOCATION:
                    {
                        [self changeLocation];
                    }
                        break;
                    case MENULOGOUT:
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
    
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


// Method needed to indicate view controller can accept unwind actions
-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    
}

-(void)returned:(UIStoryboardSegue *)segue
{
    
}
*/

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

-(void)logout
{
    AccountManager* accountManager = [AccountManager sharedAccountManager];
    
    (accountManager).delegate = self;
    
    [accountManager logoutFromDomain:nil addCompletion:^(id object) {
        
        BOOL loggedOffSuccess = [accountManager checkLoggedOut:object];
        
        if(loggedOffSuccess == TRUE){
            
            [accountManager setDelegate:nil];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }
        
    }];
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

-(void)loadingPageDismissed:(id)object
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
#pragma mark - Gesture Recognizers Delegate Methods
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    
    NSLog(@"Gesture is %@", touch.view.superview.restorationIdentifier);
    
    if([touch.view.superview.restorationIdentifier isEqualToString:MAP_VIEW])
    {
        return NO;
    }
    
    if([touch.view.superview.restorationIdentifier isEqualToString:FILTER_VIEW])
    {
        return NO;
    }
    
    if ([[touch.view.superview class] isSubclassOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    
    if([touch.view.superview.restorationIdentifier isEqualToString:ALL_DEALS_TABLE_VIEW])
    {
        return NO;
    }
    
    if([touch.view.restorationIdentifier isEqualToString:DEALS_TABLE_VIEW])
    {
        return NO;
    }
     
    
    
    return YES;
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
