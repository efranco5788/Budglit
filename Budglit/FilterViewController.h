//
//  FilterViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BudgetManager;
@class AppDelegate;
@class MapViewController;
@class LoadingLocalDealsViewController;

typedef void (^UILablesUpdated)(BOOL success);

@protocol FilterDelegate <NSObject>
@optional
-(void) dismissView;
-(void)startButtonPressed:(NSArray*)filter;
@end
@interface FilterViewController : UIViewController

@property (strong, nonatomic) id<FilterDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *viewResultsButton;
@property (strong, nonatomic) IBOutlet UILabel *budgetText;
@property (strong, nonatomic) IBOutlet UILabel *mileText;
@property (strong, nonatomic) IBOutlet UISlider* budgetSlider;
@property (strong, nonatomic) IBOutlet UISlider* distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel* lbl_DistanceMin;
@property (strong, nonatomic) IBOutlet UILabel* lbl_DistanceMax;
@property (strong, nonatomic) IBOutlet UILabel* lbl_BudgetMin;
@property (strong, nonatomic) IBOutlet UILabel* lbl_BudgetMax;
@property (strong, nonatomic) NSArray* dealsDisplayed;

+(void) setNavigationBar:(UINavigationBar*)bar;

- (IBAction)startPressed:(UIButton *)sender;

- (IBAction)dragStarted:(id)sender;

- (IBAction)dragEnded:(id)sender;

-(void)valueChanged:(UISlider*)slider;

-(void)updateLabels;

-(void)updateBudgetLabel:(NSArray*)list;

-(void)updateDistanceLabel:(NSArray*)list;

-(void)toggleButtons;

-(void) dismissView;

@end
