//
//  FilterViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "FilterViewController.h"
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
#define kDISTANCE_VALUE @"distance_key"
#define kBUDGET_VALUE @"budget_key"
#define DATE_FILTER @"date_filter"
#define BUDGET_AMOUNTS @"budget_amounts"
#define DISTANCE_AMOUNTS @"distance_amounts"
#define ANIMATION_BACKGROUND_COLOR_CHANGE @"backgroundColorChange"


@interface FilterViewController ()<BudgetManagerDelegate, DatabaseManagerDelegate, LoadingPageDelegate, LocationManagerDelegate, UIViewControllerTransitioningDelegate>
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

@implementation FilterViewController
{
    NSInteger currentState;
}
@synthesize dealsDisplayed, budgetSlider, distanceSlider, lbl_BudgetMax, lbl_BudgetMin, lbl_DistanceMax, lbl_DistanceMin;

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
    
    [self resetValues];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self.navigationItem setTitle:@"Filter"];
    
    [self.budgetSlider addTarget:self
               action:@selector(valueChanged:)
     forControlEvents:UIControlEventValueChanged];
    
    NSString* location = [appDelegate.locationManager retrieveCurrentLocationString];
    
    colorButtonAnimation = [[CABasicAnimation animationWithKeyPath:@"backgroundColor"] init];
    colorFillTransitionAnimation = [CATransition animation];
    
    location = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.viewResultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.viewResultsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
 
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

- (IBAction)startPressed:(UIButton *)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    NSArray* deals = [appDelegate.databaseManager managerGetSavedDeals];
    
    NSArray* distanceFiltered = [appDelegate.databaseManager managerFilterDeals:deals byDistance:self.distanceSlider.value];
    
    NSArray* budgetFiltered = [appDelegate.databaseManager managerFilterDeals:distanceFiltered byBudget:self.budgetSlider.value];
    
    [self saveSliderValues:@[self.budgetSlider, self.distanceSlider]];
    
    currentState = CLEAR;
    
    NSLog(@"Budget complete, app state is now clear");
    
    if(budgetFiltered.count < 1 || !budgetFiltered){
        [self.delegate startButtonPressed:nil];
    }
    else [self.delegate startButtonPressed:budgetFiltered];
}

- (IBAction)dragStarted:(id)sender {
    
    NSLog(@"drag started");
    
    [self toggleButtons];
}

- (IBAction)dragEnded:(id)sender {
    
    NSLog(@"drag ended");
    
    //[self dispalyValueForSlider:self.budgetSlider];
    [self dispalyValueForSlider:sender];
    
    [self toggleButtons];
}

-(void)valueChanged:(UISlider *)slider
{
    NSInteger newValue = (NSInteger)slider.value;
    
    [slider setValue:newValue animated:NO];
}

-(void)saveSliderValues:(NSArray*)values
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if(!values || values.count < 2) return;
    
    for (id obj in values) {
        
        UISlider* slider = (UISlider*) obj;
        
        NSNumber* numberValue = [NSNumber numberWithFloat:slider.value];
        
        if(slider.tag == 0) [defaults setValue:numberValue forKey:kDISTANCE_VALUE];
        else if (slider.tag == 1) [defaults setValue:numberValue forKey:kBUDGET_VALUE];
    }
    
}

-(NSNumber*)getSliderValuesForSlider:(UISlider*)slider;
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if(!slider) return nil;
    
    NSNumber* value = nil;
    
    if(slider.tag == 0){
        value = [defaults valueForKey:kDISTANCE_VALUE];
    }
    else if (slider.tag == 1){
        value = [defaults valueForKey:kBUDGET_VALUE];
    }
    
    if(!value) return nil;
    
    return value;
    
}

-(void)resetValues{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kDISTANCE_VALUE];
    
    [defaults removeObjectForKey:kBUDGET_VALUE];
    
    [defaults synchronize];
}

-(void)dispalyValueForSlider:(UISlider *)slider
{
    if(slider){
        
        if(slider.minimumValue <= 0 && slider.maximumValue <= 0){
            slider.maximumValue = 1;
        }
        else{
            
            float sliderRange = slider.frame.size.width - slider.currentThumbImage.size.width;
            
            float sliderOrigin = slider.frame.origin.x + (slider.currentThumbImage.size.width / 2);
            
            NSInteger sliderValue = (NSInteger) floor(slider.value);
            
            //float sliderValueToPixels = (((sliderValue - slider.minimumValue)/(slider.maximumValue - slider.minimumValue)) * sliderRange) + sliderOrigin;
            
            float sliderValueToPixels = (((sliderValue - slider.minimumValue)/(slider.maximumValue - slider.minimumValue)) * sliderRange) + sliderOrigin;
            
            //NSLog(@"slider.frame.origin.x = %f", slider.frame.origin.x + slider.frame.size.width);
            
            NSLog(@"sliderValue = %ld", (long)sliderValueToPixels);
            
            if(sliderValueToPixels < slider.frame.origin.x){
                
            }
            else if(sliderValueToPixels > (slider.frame.origin.x + slider.frame.size.width)){
                
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
            
        } // end of max and min value if statement
        
    } // end of slider value if statement
    
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

-(void)updateLabels
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* deals = [appDelegate.databaseManager managerGetSavedDeals];
    
    if(deals && deals.count > 0){
        
        [self updateBudgetLabel:deals];
        
        [self updateDistanceLabel:deals];
        
    }
    
}

-(void)updateBudgetLabel:(NSArray*)list
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* minimumBudgetLbl = MINIMUM_BUDGET_LBL_DEFAULT;
    NSString* maximumBudgetLbl = MAXIMUM_BUDGET_LBL_DEFAULT;
    
    NSInteger lowestBudget = [appDelegate.databaseManager managerGetLowestBudgetFromDeals:list];
    NSInteger highestBudget = [appDelegate.databaseManager managerGetHighestBudgetFromDeals:list];
    
    if(lowestBudget < 0){
        
        minimumBudgetLbl = [NSString stringWithFormat:@"0"];
        [self.budgetSlider setMinimumValue:0];
        
    }
    else if (lowestBudget == 0){
        
        minimumBudgetLbl = [NSString stringWithFormat:@"Free"];
        [self.budgetSlider setMinimumValue:lowestBudget];
        
    }
    else{
        
        minimumBudgetLbl = [NSString stringWithFormat:@"$ %@.00", [[NSNumber numberWithInteger:lowestBudget] stringValue]];
        [self.budgetSlider setMinimumValue:lowestBudget];
    }
    
    
    
    if(highestBudget < 0){
        
    }
    else if (highestBudget == 0){
        
    }
    else{
        
        maximumBudgetLbl = [NSString stringWithFormat:@"$ %@.00", [[NSNumber numberWithInteger:highestBudget] stringValue]];
        
        [self.budgetSlider setMaximumValue:highestBudget];
    }
    
    NSNumber* valueObj = [self getSliderValuesForSlider:self.budgetSlider];
    
    if(!valueObj) [self.budgetSlider setValue:highestBudget];
    else{
        float value = valueObj.floatValue;
        [self.budgetSlider setValue:value];
    }
    
    [self.lbl_BudgetMin setText:minimumBudgetLbl];
    [self.lbl_BudgetMax setText:maximumBudgetLbl];
}


-(void)updateDistanceLabel:(NSArray *)list
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* maximumDistanceLbl = MAXIMUM_DISTANCE_LBL_DEFAULT;
    NSString* minimumDistanceLbl = MINIMUM_DISTANCE_LBL_DEFAULT;

    NSInteger minDistance = [appDelegate.locationManager managerGetShortestDistanceFromDeals:list];
    NSInteger maxDistance = [appDelegate.locationManager managerGetLongestDistanceFromDeals:list];
    
    
    if(minDistance <= -1) {
        
    }
    else if (minDistance == 0) {
        
        minimumDistanceLbl = [NSString stringWithFormat:@"Under a mile"];
        
    }
    else if (minDistance > 0) {
        
        //minDistance = floor(convertedDistance);
        minimumDistanceLbl = [NSString stringWithFormat:@"%@ mi", [NSNumber numberWithInteger:minDistance]];
        
    }
    
    
    if (maxDistance < minDistance){
        
        //maxDistance = ceil(convertedDistance);
        
        
    }
    else if (maxDistance == 0){
        
        maximumDistanceLbl = [NSString stringWithFormat:@"Under %@ mi", [NSNumber numberWithInteger:maxDistance]];
        
    }
    else if (maxDistance > 0){
        
        maximumDistanceLbl = [NSString stringWithFormat:@"%@ mi", [NSNumber numberWithInteger:maxDistance]];
        
        [self.distanceSlider setMaximumValue:maxDistance];
    }
    
    NSNumber* valueObj = [self getSliderValuesForSlider:self.distanceSlider];
    
    if(!valueObj) [self.distanceSlider setValue:maxDistance];
    else{
        float value = valueObj.floatValue;
        [self.distanceSlider setValue:value];
    }
    
    
    [self.lbl_DistanceMin setText:minimumDistanceLbl];
    [self.lbl_DistanceMax setText:maximumDistanceLbl];
    
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
