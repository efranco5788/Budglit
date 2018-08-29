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

#define MINIMUM_BUDGET_LBL_DEFAULT @"Free"
#define MAXIMUM_BUDGET_LBL_DEFAULT @"Expensive"
#define MINIMUM_DISTANCE_LBL_DEFAULT @"Under 1 mile"
#define MAXIMUM_DISTANCE_LBL_DEFAULT @"0"
#define DATE_FILTER @"date_filter"
#define BUDGET_AMOUNTS @"budget_amounts"
#define DISTANCE_AMOUNTS @"distance_amounts"
#define ANIMATION_BACKGROUND_COLOR_CHANGE @"backgroundColorChange"


@interface BudgetPickerViewController ()<BudgetManagerDelegate, DatabaseManagerDelegate, LoadingPageDelegate, LocationManagerDelegate, UIViewControllerTransitioningDelegate>
{
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
    
    self.transitioningDelegate = self;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self.navigationItem setTitle:@"Filter"];
    
    [self.budgetSlider addTarget:self
               action:@selector(valueChanged:)
     forControlEvents:UIControlEventValueChanged];
    
    NSString* location = [appDelegate.locationManager retrieveCurrentLocationString];

    if (self.budgetAmounts == nil) {
        self.budgetAmounts = @[@"Free", @"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", @"60", @"65", @"70", @"75", @"80", @"85", @"90", @"95", @"100"];
    }

    
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
 
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // Update the current results
    //NSDictionary* criteria = @{NSLocalizedString(@"DISTANCE_FILTER", nil): distance};
    
    [self.viewResultsButton setEnabled:NO];
    
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

    NSArray* deals = [appDelegate.databaseManager managerGetSavedDeals];
    
    NSArray* filtered = [appDelegate.databaseManager managerFilterDeals:deals byBudget:self.budgetSlider.value];
    
    currentState = CLEAR;
    
    //[self.delegate dismissView];
    
    NSLog(@"Budget complete, app state is now clear");
    
    if(filtered.count < 1 || !filtered){
        [self.delegate startButtonPressed:nil];
    }
    else [self.delegate startButtonPressed:filtered];
}

- (IBAction)dragStarted:(id)sender {
    
    [self toggleButtons];

}

- (IBAction)dragEnded:(id)sender {
    
    [self dispalyValueForSlider:self.budgetSlider];
    
    [self toggleButtons];

}

-(void)valueChanged:(UISlider *)slider
{
    NSInteger newValue = (NSInteger)slider.value;
    
    [slider setValue:newValue animated:NO];
    
    //[slider setValue:((int)((slider.value + 2.5) / 5) * 5) animated:NO];
}

-(void)dispalyValueForSlider:(UISlider *)slider
{
    float sliderRange = slider.frame.size.width - slider.currentThumbImage.size.width;
    
    float sliderOrigin = slider.frame.origin.x + (slider.currentThumbImage.size.width / 2);
    
    NSInteger sliderValue = (NSInteger) floor(slider.value);
    
    float sliderValueToPixels = (((sliderValue - slider.minimumValue)/(slider.maximumValue - slider.minimumValue)) * sliderRange) + sliderOrigin;
    
    NSLog(@"slider.frame.origin.x = %f", slider.frame.origin.x + slider.frame.size.width);
    
    NSLog(@"sliderValueToPixels = %f", sliderValueToPixels);
    
    if(sliderValueToPixels == slider.frame.origin.x){
        
    }
    else if(sliderValueToPixels >= slider.frame.origin.x + slider.frame.size.width){
        
    }
    else{
        
        float sliderValueY = (slider.frame.origin.y - 40);
        
        float lblSize = slider.frame.size.width / 8;
        
        CGRect lblFrame = CGRectMake(sliderValueToPixels, sliderValueY, lblSize, lblSize);
        
        __block UILabel* valueDisplayLbl = [[UILabel alloc] initWithFrame:lblFrame];
        
        valueDisplayLbl.adjustsFontSizeToFitWidth = YES;
        
        [valueDisplayLbl setText:[NSString stringWithFormat:@"%li", (long)sliderValue]];
        
        [self.view addSubview:valueDisplayLbl];
        
        NSTimer* hideDisplay = [NSTimer timerWithTimeInterval:0.5f repeats:NO block:^(NSTimer * _Nonnull timer) {
            
            [UIView animateWithDuration:0.5f animations:^{
                
                [valueDisplayLbl setAlpha:0.0f];
                
            } completion:^(BOOL finished) {
                [valueDisplayLbl removeFromSuperview];
            }];
        }];
        
        [hideDisplay fire];
        
    }
    
}

-(void)updateLabels
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* deals = [appDelegate.databaseManager managerGetSavedDeals];
    
    NSString* minimumBudgetLbl = MINIMUM_BUDGET_LBL_DEFAULT;
    
    NSString* maximumBudgetLbl = MAXIMUM_BUDGET_LBL_DEFAULT;
    
    NSString* maximumDistanceLbl = MAXIMUM_DISTANCE_LBL_DEFAULT;
    
    NSString* minimumDistanceLbl = MINIMUM_DISTANCE_LBL_DEFAULT;

    int minDistance = -1;
    
    int maxDistance = -1;
    
    if (deals.count > 0) {
        
        NSInteger lowestBudget = [appDelegate.databaseManager managerGetLowestBudgetFromDeals:deals];
        
        NSInteger highestBudget = [appDelegate.databaseManager managerGetHighestBudgetFromDeals:deals];
        
        if(lowestBudget <= 0){
            minimumBudgetLbl = [NSString stringWithFormat:@"Free"];
        }
        else minimumBudgetLbl = [NSString stringWithFormat:@"$ %@.00", [[NSNumber numberWithInteger:lowestBudget] stringValue]];
        
        [self.budgetSlider setMinimumValue:lowestBudget];
        
        maximumBudgetLbl = [NSString stringWithFormat:@"$ %@.00", [[NSNumber numberWithInteger:highestBudget] stringValue]];
        
        [self.budgetSlider setMaximumValue:highestBudget];
        [self.budgetSlider setValue:highestBudget];
        
        for (Deal* deal in deals) {
            
            CLLocation* evntLocation = [appDelegate.locationManager managerConvertAddressToLocation:deal.googleAddressInfo];

            CLLocationDistance totalDistance = [appDelegate.locationManager managerDistanceFromLocation:evntLocation toLocation:[appDelegate.locationManager getCurrentLocation]];
            
            CLLocationDistance convertedDistance = [appDelegate.locationManager managerConvertDistance:totalDistance];
            
            minDistance = floor(convertedDistance);
            
            if(minDistance <= -1) {
                
                minimumDistanceLbl = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:convertedDistance]];

            }
            else if (minDistance == 0) {
                
                minimumDistanceLbl = [NSString stringWithFormat:@"Under a mile"];
                
            }
            else if (convertedDistance < minDistance) {
                
                minDistance = floor(convertedDistance);
                
                minimumDistanceLbl = [NSString stringWithFormat:@"%@ mi", [NSNumber numberWithInteger:minDistance]];
                
            }
            
            
            if (maxDistance < convertedDistance){
                
                maxDistance = ceil(convertedDistance);
                
                maximumDistanceLbl = [NSString stringWithFormat:@"Under %@ mi", [NSNumber numberWithInteger:maxDistance]];
            }
            

        }
    }
    
    [self.lbl_BudgetMin setText:minimumBudgetLbl];
    
    [self.lbl_BudgetMax setText:maximumBudgetLbl];
    
    [self.lbl_DistanceMin setText:minimumDistanceLbl];
    
    [self.lbl_DistanceMax setText:maximumDistanceLbl];
}

-(void)toggleButtons
{

    if ((self.viewResultsButton).enabled) {
        
        currentState = BUSY;
        
        [self.viewResultsButton.layer removeAnimationForKey:ANIMATION_BACKGROUND_COLOR_CHANGE];
        [self.viewResultsButton setEnabled:NO];
        
        //NSLog(@"Buttons are now disabled");
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
