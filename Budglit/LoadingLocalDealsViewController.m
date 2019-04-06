//
//  LoadingLocalDealsViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//
#import "LoadingLocalDealsViewController.h"
#import "AppDelegate.h"
#import "Deal.h"
#import "BudgetManager.h"
#import "DatabaseManager.h"
#import "LocationServiceManager.h"
#import "PSEditZipcodeOfflineTableViewController.h"
#import "PSAllDealsTableViewController.h"
#import "DismissTransitionFromBudgetViewController.h"

#import "UINavigationController+CompletionHandler.h"

#define BUDGET_TITLE @"Budget"
#define BUDGET_EDIT_ALERT_VIEW_TITLE @"Edit Budget"
#define ZIPCODE_INPUT @"Input Zipcode"
#define ZIPCODE @"zipcode"

#define DISTANCE_FILTER @"distance_filter"
#define DATE_FILTER @"date_filter"
#define BUDGET_AMOUNTS @"budget_amounts"
#define DISTANCE_AMOUNTS @"distance_amounts"


#define KEY_TMP_LOCATION @"tmpLocation"

#define EDIT_ZIPCODE_OFFLINE_VIEW_CONTROLLER @"EditZipcodeOffline_TableViewController"

@interface LoadingLocalDealsViewController () <LocationManagerDelegate, DatabaseManagerDelegate, EditZipcodeOfflineDelegate>

@property (nonatomic, strong) NSDictionary* tmpCriteriaStorage;
@property (nonatomic, strong) UIView* backgroundDimmer;

@end

typedef NS_ENUM(NSInteger, UICurrentState) {
    CLEAR = 0,
    BUSY = 1,
    GATHERING_LOCATION = 2,
    GATHER_OFFLINE_LOCATION = 3,
    GATHERING_BUDGET = 4
};

@implementation LoadingLocalDealsViewController
{
    NSInteger currentTotalDealCount;
    int currentState;
}
@synthesize delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        (self.navigationItem).title = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationClass = [self class];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.hidesBackButton = YES;
    
    if (self.backgroundDimmer == nil) {
        [self addBackgroundDimmerView];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self.activityIndicator startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationReactivated) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    currentState = CLEAR;
    NSLog(@"State is clear");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    currentState = CLEAR;
    
    [self.activityIndicator stopAnimating];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSLog(@"Loading page now being dismissed, app state is clear");
}

-(void)applicationReactivated
{
    
}

-(void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Database Delegates
-(void)managerDealsDidNotLoad
{
    
    UIAlertController* dealsAlert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Seems to be some connectivity issues" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.delegate loadingPageDismissed:nil];
        
    }];
    
    [dealsAlert addAction:retryAction];
    [dealsAlert addAction:cancelAction];
    
    [self presentViewController:dealsAlert animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Background Dimmer Methods
-(void) addBackgroundDimmerView
{
    if (!self.backgroundDimmer) {
        
        self.backgroundDimmer = [[UIView alloc] initWithFrame:self.view.bounds];
        
        self.backgroundDimmer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    UIColor* dimmerColor = [UIColor blackColor];
    
    (self.backgroundDimmer).backgroundColor = dimmerColor;
    
    (self.backgroundDimmer).alpha = 0.5;
    
    [self.backgroundDimmer setHidden:YES];
    
    [self.view addSubview:self.backgroundDimmer];
}

-(void) toggleBackgroundDimmer
{
    if ((self.backgroundDimmer).hidden) {
        [self.backgroundDimmer setHidden:NO];
    }
    else
    {
        [self.backgroundDimmer setHidden:YES];
    }
}

#pragma mark -
#pragma mark - Text Field delagate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 100) {

        LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
        
        if (![locationManager validateZipcodeInput:string withOldString:textField.text]) {
            return NO;
        }
        else{
            return YES;
        }
    }
    else return YES;
}

#pragma mark - User Current Location
-(void)fetchInitialUserLocationOffline
{
    UIAlertController* zipcode_Alert = [UIAlertController alertControllerWithTitle:ZIPCODE_INPUT message:@"Invalid. Please enter an exisiting Zipcode or Enable Location Services" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [zipcode_Alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [zipcode_Alert addAction:done];
    
    [zipcode_Alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 100;
        textField.delegate = self;
        [textField becomeFirstResponder];
    }];
    
    [self presentViewController:zipcode_Alert animated:YES completion:nil];
}

-(void)fetchUserLocationOfflineHideBackButton:(BOOL)hide
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PSEditZipcodeOfflineTableViewController* editZipcodeViewController = [storyboard instantiateViewControllerWithIdentifier:EDIT_ZIPCODE_OFFLINE_VIEW_CONTROLLER];
    
    editZipcodeViewController.delegate = self;
    
    self.editOfflinePage = editZipcodeViewController;
    
    editZipcodeViewController = nil;
    
    [self.navigationController completionhandler_pushViewController:self.editOfflinePage withController:self.navigationController animated:YES completion:^{
        
        [self.editOfflinePage hideBackButton:hide];
        
    }];
    
}

-(void)fetchUserLocationOnline
{
    currentState = GATHERING_LOCATION;
    
    NSLog(@"Gathering user's location");

    LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
    
    (locationManager).delegate = self;
    
    [locationManager startUpdates];
}


#pragma mark -
#pragma mark - Location Manager Delegate
-(void)locationDidFinish
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];

    NSDictionary* appDefaults = [databaseManager managerGetUsersCurrentCriteria];
    
    if(!appDefaults || appDefaults.count == 0){
        
        appDefaults = [databaseManager managerFetchPrimaryDefaultSearchFiltersWithLocation];
        
    }
    
    [databaseManager managerSaveUsersCriteria:appDefaults];

    [self.delegate loadingPageDismissed:appDefaults];
    
}

-(void)onlineAttemptFailed
{
    currentState = CLEAR;
    
    NSLog(@"Could not gather user's location. App state is now clear");
    
    [self fetchInitialUserLocationOffline];
    
    NSLog(@"Attempting user offline location");
}

#pragma mark - Edit Zipcode Offline Delegate
-(void)locationUpdated
{
    [self.navigationController completionhandler_popViewControllerAnimated:YES navigationController:self.navigationController completion:^{
        
        self.editOfflinePage = nil;
        
    }];
    
}

-(void)dismissZipcodeController
{
    //[self.navigationController popViewControllerAnimated:NO];
    [self.delegate loadingPageDismissed:nil];
}

/*
#pragma mark -
#pragma mark - Navigation Delegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    

}
*/

#pragma mark -
#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
}

@end
