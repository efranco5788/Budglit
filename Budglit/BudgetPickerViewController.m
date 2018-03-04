//
//  BudgetPickerViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "BudgetPickerViewController.h"
#import "AppDelegate.h"
#import "BudgetManager.h"
#import "DatabaseManager.h"
#import "MapViewController.h"
#import "LoadingLocalDealsViewController.h"
#import "LocationServiceManager.h"
#import "PostalCode.h"
#import "math.h"
#import <dispatch/dispatch.h>

#define MINIMUM_BUDGET_LABEL_DEFAULT @"Free"
#define DATE_FILTER @"date_filter"
#define BUDGET_AMOUNTS @"budget_amounts"
#define DISTANCE_AMOUNTS @"distance_amounts"
#define ANIMATION_BACKGROUND_COLOR_CHANGE @"backgroundColorChange"


@interface BudgetPickerViewController ()<BudgetManagerDelegate, DatabaseManagerDelegate, LoadingPageDelegate, LocationManagerDelegate, UIViewControllerTransitioningDelegate>
{
    NSUInteger currentBudgetPickerValue;
    NSUInteger currentDistanceValue;
    NSArray* currentSurroundingZipcodes;
    dispatch_queue_t backgroundQueue;
    
    CABasicAnimation* colorButtonAnimation;
    CATransition* colorFillTransitionAnimation;
}

@end

typedef NS_ENUM(NSInteger, UICurrentState) {
    CLEAR = 0,
    BUSY = 1,
    UPDATING_LABELS = 2
};

@implementation BudgetPickerViewController
{
    NSInteger currentState;
}
@synthesize distanceFilterSegment, budgetSlider, distanceSlider, budgetAmounts, lbl_BudgetMax, lbl_BudgetMin, lbl_DistanceMax, lbl_DistanceMin;

+(void) setNavigationBar:(UINavigationBar*)bar {
    
    [bar setBarTintColor:[UIColor colorWithRed:31.0/255.0 green:80.0/255.0 blue:155.0/255.0 alpha:1.0]];
    
    [bar setTintColor:[UIColor whiteColor]];
    
    NSDictionary* titleAttributes = @{
                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                      NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:21.0]
                                      };
    
    [bar setTitleTextAttributes:titleAttributes];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    currentState = CLEAR;
    
    self.transitioningDelegate = self;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self.navigationItem setTitle:@"Filter"];
    
    NSString* location = [appDelegate.locationManager retrieveCurrentLocationString];

    if (self.budgetAmounts == nil) {
        self.budgetAmounts = @[@"Free", @"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", @"60", @"65", @"70", @"75", @"80", @"85", @"90", @"95", @"100"];
    }
    
    currentDistanceValue = 1;
    
    [self configureBlocks];
    
    colorButtonAnimation = [[CABasicAnimation animationWithKeyPath:@"backgroundColor"] init];
    colorFillTransitionAnimation = [CATransition animation];
    
    location = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.viewResultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.viewResultsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    if (self.budgetFilterBlock == nil) {
        
        [self configureBlocks];
    }
    
    currentSurroundingZipcodes = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString* distance = [NSString stringWithFormat:@"%li", (long)currentDistanceValue];
    
    // Update the current results
    NSDictionary* criteria = @{NSLocalizedString(@"DISTANCE_FILTER", nil): distance};
    
    
    [self toggleButtons];
    
    [self updateLabels];
    
    [self updateSearchLables:^(BOOL success) {

        [self updateViewLabels:self.currentFilterCriteria_Labels addCompletion:^(BOOL success) {
            
            [self fetchSurroundingZipcodes:criteria];
            
        }];
        
    }];
    
     
}

-(void)configureBlocks
{
    BudgetPickerViewController* __weak weakSelf = self;
    
    self.budgetFilterBlock = ^NSString*{
        
        NSInteger budgetValue = floorf(weakSelf.budgetSlider.value);
        
        NSString* budgetCriteria;
        
        if (budgetValue == 0) {
            budgetCriteria = NSLocalizedString(@"FREE_FILTER", nil);
            
        }
        else
        {
            NSString* dollarAmountToNearestTenth = [NSString stringWithFormat:@"%@%@",(weakSelf.budgetAmounts)[budgetValue], NSLocalizedString(@"DOLLAR_ROUDED_NEAREST_TENTH", nil)];
            
            budgetCriteria = dollarAmountToNearestTenth;
        }
        
        return budgetCriteria;
    };
}

- (IBAction)startPressed:(UIButton *)sender {
    
    NSDictionary* criteria = [self getCurrentSearchCriteria];
    
    //[self.delegate budgetSelected:criteria];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    [appDelegate.databaseManager saveUsersCriteria:criteria];
    
    currentState = CLEAR;
    
    [self.delegate dismissView];
    
    NSLog(@"Budget complete, app state is now clear");
}

- (IBAction)dragStarted:(id)sender {

}

- (IBAction)dragged:(id)sender {
    
    [self updateSearchLables:^(BOOL success) {
        
        [self updateViewLabels:self.currentFilterCriteria_Labels addCompletion:^(BOOL success) {
            
        }];
        
    }];
}

- (IBAction)dragEnded:(id)sender {
    
    //Update current results
    NSDictionary* criteria = [self getCurrentSearchCriteria];
    
    if (currentState == CLEAR) {
        
        [self toggleButtons];
        
        // method called to update the search results
        [self reloadDealResultsReturnCount:criteria];
        
    }
    else if (currentState == BUSY) {
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [appDelegate.databaseManager cancelDownloads:^(BOOL success) {
            
            if (success) {
                
                [self toggleButtons];
                
                [self reloadDealResultsReturnCount:criteria];
                
            }
            
        }];
        
    }

}

- (IBAction)distanceFilterSegement_Action:(id)sender {
    
    if (currentState == BUSY) {
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [appDelegate.databaseManager cancelDownloads:^(BOOL success) {
            
            if (success) {
                
                [self toggleButtons];
                
                if (self.distanceFilterSegment.selectedSegmentIndex == 0) {
                    currentDistanceValue = 1;
                }
                else if (self.distanceFilterSegment.selectedSegmentIndex == 1)
                {
                    currentDistanceValue = 5;
                }
                else if (self.distanceFilterSegment.selectedSegmentIndex == 2)
                {
                    currentDistanceValue = 10;
                }
                else if (self.distanceFilterSegment.selectedSegmentIndex == 3)
                {
                    currentDistanceValue = 15;
                }
                else currentDistanceValue = 1;
                
                NSString* distance = [NSString stringWithFormat:@"%li", (long)currentDistanceValue];
                
                // Update the current results
                NSDictionary* criteria = @{NSLocalizedString(@"DISTANCE_FILTER", nil): distance};
                
                [self fetchSurroundingZipcodes:criteria];
                
            }
            
        }];
        
    }
    else if (currentState == CLEAR) {
        
        [self toggleButtons];
        
        if (self.distanceFilterSegment.selectedSegmentIndex == 0) {
            currentDistanceValue = 1;
        }
        else if (self.distanceFilterSegment.selectedSegmentIndex == 1)
        {
            currentDistanceValue = 5;
        }
        else if (self.distanceFilterSegment.selectedSegmentIndex == 2)
        {
            currentDistanceValue = 10;
        }
        else if (self.distanceFilterSegment.selectedSegmentIndex == 3)
        {
            currentDistanceValue = 15;
        }
        else currentDistanceValue = 1;
        
        NSString* distance = [NSString stringWithFormat:@"%li", (long)currentDistanceValue];
        
        // Update the current results
        NSDictionary* criteria = @{NSLocalizedString(@"DISTANCE_FILTER", nil): distance};
        
        [self fetchSurroundingZipcodes:criteria];
    }
    
}

-(void)updateLabels
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    CLLocation* userLocation = [appDelegate.locationManager getCurrentLocation];
    
    NSArray* deals = [appDelegate.databaseManager getSavedDeals];
    
    NSString* minimumBudgetLbl = MINIMUM_BUDGET_LABEL_DEFAULT;
    
    NSString* maximumBudgetLbl = @"Expensive";
    
    double min = 0.00;
    
    double max = 0.00;
    
    if (deals.count > 0) {
        for (Deal* deal in deals) {
            double budget = [deal getBudget];
            
            if (budget < min) {
                minimumBudgetLbl = [[NSNumber numberWithDouble:budget] stringValue];
                min = budget;
            }
            else if (budget > max)
            {
                maximumBudgetLbl = [[NSNumber numberWithDouble:budget] stringValue];
                max = budget;
            }
        }
    }
    
    [self.lbl_BudgetMin setText:minimumBudgetLbl];
    
    [self.lbl_BudgetMax setText:maximumBudgetLbl];
}

-(void)updateSearchLables:(UILablesUpdated)completionHandler
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userZipcode = [defaults valueForKey:NSLocalizedString(@"ZIPCODE", nil)];
    
    NSInteger budgetValue = floorf(self.budgetSlider.value);
    
    currentBudgetPickerValue = budgetValue; // Set the current values of the pickers
    
    NSString* budgetCriteria = (@(budgetValue)).stringValue;
    
    NSArray* keys = @[NSLocalizedString(@"BUDGET_FILTER", nil), NSLocalizedString(@"BUDGET_AMOUNTS", nil), NSLocalizedString(@"ZIPCODE", nil)];
    
    NSArray* values = @[budgetCriteria, self.budgetAmounts, userZipcode];
    
    NSDictionary* filterCriteria = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    self.currentFilterCriteria_Labels = filterCriteria;
    
    completionHandler(YES);
    
    userZipcode = nil;
    filterCriteria = nil;
    budgetCriteria = nil;
    keys = nil;
    values = nil;
}

-(void)updateViewLabels:(NSDictionary *)searchCriteria addCompletion:(UILablesUpdated)completionHandler
{
    NSString* budgetCriteria;
    
    NSString* budgetValue = [searchCriteria valueForKey:NSLocalizedString(@"BUDGET_FILTER", nil)];
    
    NSArray* budgetAmounts = [searchCriteria valueForKey:BUDGET_AMOUNTS];
    
    NSInteger budget = budgetValue.integerValue;
    
    completionHandler(YES);
}

-(NSDictionary*)getCurrentSearchCriteria
{
    NSDictionary* filterCriteria;
    
    if (currentSurroundingZipcodes != nil) {
        filterCriteria = [self getCurrentSearchCriteriaWithSurrondingZipcodes:currentSurroundingZipcodes];
        
    }
    else{filterCriteria = [self getCurrentSearchCriteriaWithSurrondingZipcodes:nil];
    }
    
    return filterCriteria;
}

-(NSDictionary *)getCurrentSearchCriteriaWithSurrondingZipcodes:(NSArray *)zipcodes
{
    NSString* distanceCriteria = [NSString stringWithFormat:@"%li", (long)currentDistanceValue];
    
    NSString* budgetCriteria = self.budgetFilterBlock();
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userZipcode = [defaults valueForKey:NSLocalizedString(@"ZIPCODE", nil)];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* currentDate = [appDelegate.databaseManager getCurrentDate];
    
    NSArray* keys = @[NSLocalizedString(@"DISTANCE_FILTER", nil), NSLocalizedString(@"BUDGET_FILTER", nil), NSLocalizedString(@"DATE_FILTER", nil), NSLocalizedString(@"ZIPCODE", nil), NSLocalizedString(@"SURROUNDING_ZIPCODES", nil)];
    
    NSArray* values;
    
    if (zipcodes.count < 2) {
        
        values = @[distanceCriteria, budgetCriteria, currentDate, userZipcode, NSLocalizedString(@"EMPTY_SURROUNDING_ZIPCODES", nil)];
        
    }
    else{
        
        values = @[distanceCriteria, budgetCriteria, currentDate, userZipcode, zipcodes];
    }
    
    NSDictionary* filterCriteria = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    distanceCriteria = nil;
    budgetCriteria = nil;
    currentDate = nil;
    userZipcode = nil;
    defaults = nil;
    keys = nil;
    values = nil;
    
    return filterCriteria;
}

-(void)reloadDealResultsReturnCount:(NSDictionary *)searchCriteria
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    [appDelegate.databaseManager fetchTotalDealCountOnly:searchCriteria addCompletionBlock:^(BOOL success) {
        
        if(success){
            [self toggleButtons];
            
        }

        
    }];
    
}

-(void)toggleButtons
{
    if ((self.viewResultsButton).enabled) {
        
        currentState = BUSY;
        
        [self.viewResultsButton.layer removeAnimationForKey:ANIMATION_BACKGROUND_COLOR_CHANGE];
        [self.viewResultsButton setEnabled:NO];
        
        NSLog(@"Buttons are now disabled");
    }
    else{
        currentState = CLEAR;
        colorButtonAnimation.fromValue = (__bridge id _Nullable)([UIColor whiteColor].CGColor);
        
        UIColor* toColor = [UIColor colorWithRed:249.0f/255.0f
                        green:60.0f/255.0f
                         blue:43.0f/255.0f
                        alpha:1.0f];
        
        colorButtonAnimation.toValue = (__bridge id _Nullable)(toColor.CGColor);
        
        
        colorFillTransitionAnimation.type = kCATransitionMoveIn;
        colorFillTransitionAnimation.subtype = kCATransitionFromLeft;
        
        CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[colorFillTransitionAnimation, colorButtonAnimation];
        animationGroup.duration = 0.1;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        
        [self.viewResultsButton.layer addAnimation:animationGroup forKey:@"backgroundColorChange"];
        
        [self.viewResultsButton setEnabled:YES];
        
        [self.view setNeedsDisplay];
        
        NSLog(@"Button are now enabled");
    }
}

-(void)fetchSurroundingZipcodes:(NSDictionary *)criteria
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.locationManager).delegate = self;
    
    NSString* usersZipcode = [appDelegate.locationManager getCurrentZipcode];
    
    if ([usersZipcode isEqualToString:NSLocalizedString(@"DEFAULT_ZIPCODE", nil)] || [usersZipcode isEqual:nil])
    {
        [appDelegate.locationManager fetchSurroundingZipcodesWithCurrentLocation:nil andObjects:criteria addCompletionHandler:^(id object) {
            
            if(object){
                
                NSArray* zipcodes = (NSArray*)object;
                
                NSMutableArray* postalCodes = [[NSMutableArray alloc] init];
                
                for (PostalCode* zipcode in zipcodes) {
                    [postalCodes addObject:zipcode.postalCode];
                }
                
                currentSurroundingZipcodes = postalCodes.copy;
                
                NSDictionary* criteria = [self getCurrentSearchCriteriaWithSurrondingZipcodes:currentSurroundingZipcodes];
                
                [self reloadDealResultsReturnCount:criteria];
                
            }
            
        }];
    }
    else
    {
        [appDelegate.locationManager fetchSurroundingZipcodesWithPostalCode:usersZipcode andObjects:criteria addCompletionHandler:^(id object) {
            
            if(object){
                
                NSArray* zipcodes = (NSArray*)object;
                
                NSMutableArray* postalCodes = [[NSMutableArray alloc] init];
                
                for (PostalCode* zipcode in zipcodes) {
                    [postalCodes addObject:zipcode.postalCode];
                }
                
                currentSurroundingZipcodes = postalCodes.copy;
                
                NSDictionary* criteria = [self getCurrentSearchCriteriaWithSurrondingZipcodes:currentSurroundingZipcodes];
                
                [self reloadDealResultsReturnCount:criteria];
                
            }
            
        }];
    }
}

#pragma mark -
#pragma mark - Navigation
-(void)dismissView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return nil;
}

#pragma mark -
#pragma mark - Database Manager Delegate
-(void)totalCountReattempt:(NSDictionary *)criteria
{
    [self reloadDealResultsReturnCount:criteria];
}

-(void)totalCountFailed
{
    UIAlertController* menuView = [UIAlertController alertControllerWithTitle:nil message:@"I'm sorry but we seem to be experiencing some technical issues." preferredStyle:UIAlertControllerStyleAlert];
    
    __block UIAlertAction* actionRetry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    __block UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [menuView addAction:actionRetry];
    [menuView addAction:actionCancel];
    
    [self presentViewController:menuView animated:YES completion:^{
        
        actionRetry = nil;
        actionCancel = nil;
        
    }];
}

-(void)dealsDidNotLoad
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"There was a connectivity issue." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* attempt = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toggleButtons];
    }];
    
    [alert addAction:attempt];
    
    [self presentViewController:alert animated:NO completion:nil];
}

/*
#pragma mark -
#pragma mark - Location Manager Delegate
-(void)surroundingZipcodesReturned:(NSArray *)zipcodes andCriteria:(NSDictionary *)searchCriteria
{
    NSMutableArray* postalCodes = [[NSMutableArray alloc] init];
    
    for (PostalCode* zipcode in zipcodes) {
        [postalCodes addObject:zipcode.postalCode];
    }
    
    currentSurroundingZipcodes = postalCodes.copy;
    
    NSDictionary* criteria = [self getCurrentSearchCriteriaWithSurrondingZipcodes:currentSurroundingZipcodes];
    
    [self reloadDealResultsReturnCount:criteria];
}
*/

#pragma mark -
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end
