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
@synthesize budgetSlider, distanceSlider, budgetAmounts, lbl_BudgetMax, lbl_BudgetMin, lbl_DistanceMax, lbl_DistanceMin;

+(void) setNavigationBar:(UINavigationBar*)bar {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [bar setBarTintColor:[appDelegate getPrimaryColor]];

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
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    currentState = CLEAR;
    
    [self.delegate dismissView];
    
    NSLog(@"Budget complete, app state is now clear");
}

- (IBAction)dragStarted:(id)sender {

}

- (IBAction)dragged:(id)sender {
    
}

- (IBAction)dragEnded:(id)sender {
    
    if (currentState == CLEAR) {
        
        [self toggleButtons];

        
    }
    else if (currentState == BUSY) {
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [appDelegate.databaseManager cancelDownloads:^(BOOL success) {
            
            if (success) {
                
                [self toggleButtons];
                
            }
            
        }];
        
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

-(void)updateViewLabels:(NSDictionary *)searchCriteria addCompletion:(UILablesUpdated)completionHandler
{
    NSString* budgetCriteria;
    
    NSString* budgetValue = [searchCriteria valueForKey:NSLocalizedString(@"BUDGET_FILTER", nil)];
    
    NSArray* budgetAmounts = [searchCriteria valueForKey:BUDGET_AMOUNTS];
    
    NSInteger budget = budgetValue.integerValue;
    
    completionHandler(YES);
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
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end
