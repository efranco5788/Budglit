//
//  LoadingLocalDealsViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "LoadingLocalDealsViewController.h"
#import "AppDelegate.h"
#import "LocationServiceManager.h"
#import "DatabaseManager.h"
#import "BudgetPickerViewController.h"
#import "BudgetManager.h"
#import "Deal.h"
#import "PSEditZipcodeOfflineTableViewController.h"
#import "PSAllDealsTableViewController.h"
#import "PSTransitionToBudgetViewController.h"
#import "PSDismissTransitionFromBudgetViewController.h"
#import "PostalCode.h"
#import "UINavigationController+CompletionHandler.h"

#define BUDGET_TITLE @"Budget"
#define BUDGET_EDIT_ALERT_VIEW_TITLE @"Edit Budget"
#define ZIPCODE_INPUT @"Input Zipcode"
#define ZIPCODE @"zipcode"

#define BUDGET_FILTER @"budget_filter"
#define DISTANCE_FILTER @"distance_filter"
#define DATE_FILTER @"date_filter"
#define BUDGET_AMOUNTS @"budget_amounts"
#define DISTANCE_AMOUNTS @"distance_amounts"


#define DEFAULT_BUDGET @"-1"
#define BUDGET @"budget"
#define KEY_TMP_LOCATION @"tmpLocation"

#define BUDGET_VIEW_CONTROLLER @"BudgetPickerViewController"
#define EDIT_ZIPCODE_OFFLINE_VIEW_CONTROLLER @"EditZipcodeOffline_TableViewController"

@interface LoadingLocalDealsViewController () <LocationManagerDelegate, DatabaseManagerDelegate, BudgetPickerDelegate, EditZipcodeOfflineDelegate>

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
    //UIView* backgroundDimmer;
}
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationItem setTitle:@""];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    self.restorationIdentifier = @"loadingViewController";
    
    self.view.restorationIdentifier = @"loadingView";
    */
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

/*
#pragma mark -
#pragma mark - Application Delegates
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (self.budgetPickerView) {
        [coder encodeObject:self.budgetPickerView forKey:@"budgetViewKey"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    [coder decodeObjectForKey:@"budgetViewKey"];
}
*/
 
#pragma mark -
#pragma mark - Budget Methods
-(void)inputBudget
{
    currentTotalDealCount = 0;
    
    NSLog(@"total count has been reset");
    
    [UIView animateWithDuration:3.0 animations:^{
        
        if (self.backgroundDimmer.isHidden) {
            [self toggleBackgroundDimmer];
        }
        
    } completion:^(BOOL finished) {
        
        BudgetPickerViewController* budgetView = [[BudgetPickerViewController alloc] initWithNibName:BUDGET_VIEW_CONTROLLER bundle:nil];
        
        [budgetView setDelegate:self];
        
        budgetView.view.autoresizesSubviews = YES;
        
        self.budgetPickerView = budgetView;
        
        [self.navigationController setDelegate:self];
        
        [self.navigationController pushViewController:self.budgetPickerView animated:NO];
        
    }];
    
}

-(void)verifyBudget
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    currentState = CLEAR;
    
    NSLog(@"Location complete, app state now clear");
    
    NSString* usersBudget = [appDelegate.budgetManager retreieveBudget];
    
    if ([usersBudget isEqualToString:NSLocalizedString(@"DEFAULT_BUDGET", nil)])
    {        
        [self.delegate locationHasFinished];
    }
    else
    {
        [appDelegate.locationManager setDelegate:self];
        
        NSString* currentPostal = [appDelegate.locationManager getCurrentZipcode];
        
        [appDelegate.databaseManager setZipcodeCriteria:currentPostal];
        
        NSDictionary* userSearchCriteria = [appDelegate.databaseManager getUsersCurrentCriteria];
        
        [appDelegate.locationManager fetchSurroundingZipcodesWithPostalCode:currentPostal andObjects:userSearchCriteria];
    }
}

#pragma mark - Budget Picker Delegate
-(void)updateViewLabels:(NSDictionary *)searchCriteria
{
    NSString* budgetCriteria;
    
    NSString* budgetValue = [searchCriteria valueForKey:BUDGET_FILTER];
    
    NSArray* budgetAmounts = [searchCriteria valueForKey:BUDGET_AMOUNTS];
    
    NSInteger budget = [budgetValue integerValue];
    
    if (budget == 0) {
        budgetCriteria = @"Anything that's Free!!";
    }
    else{
        budgetCriteria = [NSString stringWithFormat:@"Under $%@", [budgetAmounts objectAtIndex:budget]];
    }
    
    self.budgetPickerView.budgetText.text = budgetCriteria;
}

-(void)updateResultLabels
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInteger count = [appDelegate.databaseManager totalCountDealsLoaded];
    
    NSString* title_doneButton = [NSString stringWithFormat:@"%li Results", (long)count];
    
    self.budgetPickerView.doneButton.title = title_doneButton;
}

-(void)budgetSelected:(NSDictionary *)selectedCriteria
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager setDelegate:self];
    
    [appDelegate.databaseManager saveUsersCriteria:selectedCriteria];
    
    currentState = CLEAR;
    
    [appDelegate.budgetManager addBudget:[selectedCriteria objectForKey:BUDGET_FILTER]];
    
    if (self.budgetPickerView) {
        
        [self dismissBudgetPickerView];
    }
    else [self.delegate budgetHasFinished];
    
    NSLog(@"Budget complete, app state is now clear");
}

-(void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Database Methods
-(void) reloadDeals
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager setDelegate:self];
    
    NSDictionary* criteria = [appDelegate.databaseManager getUsersCurrentCriteria];
    
    [appDelegate.databaseManager fetchDeals:criteria];
}


#pragma mark -
#pragma mark - Database Delegates
-(void)DealsDidLoad:(BOOL)result
{
    [self.delegate newDealsFetched];
}

-(void)DealsDidNotLoad
{
    
    UIAlertController* dealsAlert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Seems to be some connectivity issues" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self reloadDeals];
        
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.delegate loadingPageDismissed];
        
    }];
    
    [dealsAlert addAction:retryAction];
    [dealsAlert addAction:cancelAction];
    
    [self presentViewController:dealsAlert animated:YES completion:nil];
}

-(void)imagesFetched
{
    NSLog(@"Images loaded sucessfully");
    
    [self.delegate loadingPageDismissed];
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
    
    [self.backgroundDimmer setBackgroundColor:dimmerColor];
    
    [self.backgroundDimmer setAlpha:0.5];
    
    [self.backgroundDimmer setHidden:YES];
    
    [self.view addSubview:self.backgroundDimmer];
}

-(void) toggleBackgroundDimmer
{
    if ([self.backgroundDimmer isHidden]) {
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
        
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        if (![appDelegate.locationManager validateZipcodeInput:string withOldString:textField.text]) {
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
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setTag:100];
        [textField setDelegate:self];
        [textField becomeFirstResponder];
    }];
    
    [self presentViewController:zipcode_Alert animated:YES completion:nil];
}

-(void)fetchUserLocationOfflineHideBackButton:(BOOL)hide
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PSEditZipcodeOfflineTableViewController* editZipcodeViewController = [storyboard instantiateViewControllerWithIdentifier:EDIT_ZIPCODE_OFFLINE_VIEW_CONTROLLER];
    
    [editZipcodeViewController setDelegate:self];
    
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
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.locationManager setDelegate:self];
    
    [appDelegate.locationManager startUpdates:self];
}


#pragma mark -
#pragma mark - Location Manager Delegate
-(void)locationDidFinish
{
    NSLog(@"Location retrieved ");
    
    [self verifyBudget];
    
}

-(void)surroundingZipcodesReturned:(NSArray *)zipcodes andCriteria:(NSDictionary *)searchCriteria
{
    NSMutableArray* postalCodes = [[NSMutableArray alloc] init];
    
    // Extract the postal codes
    for (id zipcode in zipcodes) {
        
        PostalCode* postalCode = (PostalCode*) zipcode;
        
        NSLog(@"postal code %@", postalCode.postalCode);
        
        [postalCodes addObject:postalCode.postalCode];
    }
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* criteria = [userDefault objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSMutableDictionary* mutableCriteria = [criteria mutableCopy];
    
    [mutableCriteria setValue:postalCodes forKey:NSLocalizedString(@"SURROUNDING_ZIPCODES", nil)];
    
    NSDictionary* newCriteria = mutableCriteria.copy;
    
    [userDefault setObject:newCriteria forKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    [userDefault synchronize];
    
    [self reloadDeals];
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
    
    [self verifyBudget];
    
}

-(void)dismissZipcodeController
{
    //[self.navigationController popViewControllerAnimated:NO];
    [self.delegate loadingPageDismissed];
}


#pragma mark -
#pragma mark - Navigation Delegate
-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    
    if (fromVC == self && [toVC isKindOfClass:[BudgetPickerViewController class]]) {
        
        return [[PSTransitionToBudgetViewController alloc] init];
    }
    else{
        
        return [[PSDismissTransitionFromBudgetViewController alloc] init];
    }
}

-(void) dismissBudgetPickerView
{
    [self.navigationController setDelegate:self];
    
    /*
    [self.navigationController completionhandler_popViewController:self.budgetPickerView withController:self.navigationController animated:NO completion:^{
        
        self.budgetPickerView.delegate = nil;
        
        self.budgetPickerView = nil;
        
        [self.navigationController setDelegate:nil];
        
        [self.delegate budgetHasFinished];
        
    }];
    */
    [self.navigationController completionhandler_popViewControllerAnimated:NO navigationController:self.navigationController completion:^{
        
        self.budgetPickerView.delegate = nil;
        
        self.budgetPickerView = nil;
        
        [self.navigationController setDelegate:nil];
        
        [self.delegate budgetHasFinished];
        
    }];
    
}


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
