 //
//  PSEditZipcodeOfflineTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSEditZipcodeOfflineTableViewController.h"
#import "AppDelegate.h"
#import "CityDataObject.h"
#import "LoadingLocalDealsViewController.h"
#import "PostalCode.h"
#import "PSAllDealsTableViewController.h"
#import "ZipcodeSearchDataSource.h"
#import <dispatch/dispatch.h>

#define UNWIND_TO_ALL_CURRENT_DEALS @"unwindToAllDeals"

@interface PSEditZipcodeOfflineTableViewController ()<DatabaseManagerDelegate, LocationManagerDelegate, LoadingPageDelegate>
{
    dispatch_queue_t backgroundQueue;
    NSArray* popluatedDeals;
    CGFloat statusBarHeight;
    CityDataObject* selectedCity;
}

@end

@implementation PSEditZipcodeOfflineTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] init];
    
    cancel.tintColor = [UIColor whiteColor];
    
    cancel.title = @"Cancel";
    
    cancel.target = self;
    
    cancel.action = @selector(cancelButton_pressed:);
    
    self.cancelButton = cancel;
    
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    UISearchController* controller = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    controller.searchResultsUpdater = self;
    
    controller.delegate = self;
    
    controller.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0);
    
    (controller.searchBar).keyboardType = UIKeyboardTypeDefault;
    
    controller.hidesNavigationBarDuringPresentation = YES;
    
    controller.dimsBackgroundDuringPresentation = NO;
    
    controller.definesPresentationContext = YES;
    
    controller.searchBar.placeholder = @"City, State or Zipcode";
    
    self.tableView.tableHeaderView = controller.searchBar;
    
    self.searchControl = controller;
    
    controller = nil;
    cancel = nil;
     
}

-(void)hideBackButton:(BOOL)hide
{
    if (hide) {
        
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        (self.navigationItem.leftBarButtonItem).tintColor = [UIColor clearColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    (self.tableView).delegate = self;
    
    self.tableView.scrollEnabled = NO;
    
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark -
#pragma mark - Search Controller Delegate
-(void)willPresentSearchController:(UISearchController *)searchController{
    
    [UIView animateWithDuration:0.5 delay:05. options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        
    } completion:^(BOOL finished) {
        
        ZipcodeSearchDataSource* zipcodeDataSource = [[ZipcodeSearchDataSource alloc] init];
        
        self.dataSource = zipcodeDataSource;
        
        (self.tableView).dataSource = self.dataSource;
        
        self.tableView.scrollEnabled = YES;
        
    }];
}

-(void)willDismissSearchController:(UISearchController *)searchController{
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        
        
    } completion:^(BOOL finished) {
        
        [self.searchControl.searchBar resignFirstResponder];
        
        self.tableView.scrollEnabled = NO;
        
        NSLog(@"View Dismissed!");
    }];
    
}

#pragma mark -
#pragma mark - Search Results Updating Delegate
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(backgroundQueue, ^{
        
        (self.dataSource).userSearchInput = searchController.searchBar.text;
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES
         ];
        
    });
}

#pragma mark -
#pragma mark - Table Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* selectedPostal = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
    
    for (CityDataObject* city in self.dataSource.filteredStatesData) {
        
        if ([city.postal isEqualToString:selectedPostal]) {
            selectedCity = city;
            break;
        }
        
    }
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* currentZip = [appDelegate.databaseManager getZipcode];
    
    if ([selectedCity.postal isEqualToString:currentZip]) {
        
        [self locationDidFinish];
        
    }
    else{
        
        [appDelegate.locationManager attemptToAddCurrentLocation:selectedCity addCompletionHandler:^(BOOL success) {
            
            if (success) {
                
                [self locationDidFinish];
            }
            
        }];
    }
}

#pragma mark -
#pragma mark - unwind
-(void) cancelButton_pressed:(UIBarButtonItem *)sender
{
    //[self performSegueWithIdentifier:UNWIND_TO_ALL_CURRENT_DEALS sender:self];
    [self.delegate dismissZipcodeController];
}


#pragma mark -
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:UNWIND_TO_ALL_CURRENT_DEALS]) {
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        PSAllDealsTableViewController* ACLDDVC = segue.destinationViewController;
        
        (ACLDDVC.menuButton).title = [appDelegate.locationManager retrieveCurrentLocationString];
        
        (ACLDDVC.budgetButton).title = [appDelegate.budgetManager retreieveBudget];
        
    }
}

#pragma mark -
#pragma mark - Location Manager Delegate
-(void)locationDidFinish
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.locationManager).delegate = self;
    
    [appDelegate.databaseManager setZipcodeCriteria:selectedCity.postal];
    
    //[self.searchControl setActive:NO];
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* criteria = [userDefault objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
    
    NSString* distance = criteria[NSLocalizedString(@"DISTANCE_FILTER", nil)];
    
    if (!distance) {
        
        distance = [NSString stringWithString:NSLocalizedString(@"DEFAULT_DISTANCE_FILTER", nil)];
        
    }
    
    NSDictionary* userObject = @{NSLocalizedString(@"DISTANCE_FILTER", nil): distance};
    /*
    [appDelegate.locationManager fetchSurroundingZipcodesWithPostalCode:selectedCity.postal andObjects:userObject addCompletionHandler:^(id object) {
        
        if (object) {
            
            NSArray* zipcodes = (NSArray*)object;
            
            NSMutableArray* postalCodes = [[NSMutableArray alloc] init];
            
            // Extract the postal codes
            for (id zipcode in zipcodes) {
                
                PostalCode* postalCode = (PostalCode*) zipcode;
                
                [postalCodes addObject:postalCode.postalCode];
                
            }
            
            NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
            
            NSDictionary* criteria = [userDefault objectForKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
            
            NSMutableDictionary* mutableCriteria = [criteria mutableCopy];
            
            [mutableCriteria setValue:postalCodes forKey:NSLocalizedString(@"SURROUNDING_ZIPCODES", nil)];
            
            NSDictionary* newCriteria = mutableCriteria.copy;
            
            [userDefault setObject:newCriteria forKey:NSLocalizedString(@"KEY_CURRENT_SEARCH_FILTERS", nil)];
            
            [userDefault synchronize];
            
            [self.searchControl setActive:NO];
            
            [self.delegate locationUpdated];
        }
        
    }];
     */
}

#pragma mark -
#pragma mark - Loading Page Delegate
-(void)newDealsFetched
{
    [self.delegate dismissZipcodeController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
