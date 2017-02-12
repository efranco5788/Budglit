//
//  BudgetPickerViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BudgetManager;
@class AppDelegate;
@class MapViewController;
@class DatabaseManager;
@class LoadingLocalDealsViewController;

typedef void (^UILablesUpdated)(BOOL success);

@protocol BudgetPickerDelegate <NSObject>
@optional
-(void) budgetSelected:(NSDictionary*) selectedCriteria;
-(void) updateViewLabels:(NSDictionary*) searchCriteria;
-(void) updateResultLabels;
@end
@interface BudgetPickerViewController : UIViewController

@property (nonatomic, assign) id<BudgetPickerDelegate> delegate;

@property (strong, nonatomic) MapViewController* mapView;

@property (strong, nonatomic) UIBarButtonItem* doneButton;

@property (strong, nonatomic) IBOutlet UIButton *viewResultsButton;

@property (strong, nonatomic) IBOutlet UILabel *currentLocationText;

@property (strong, nonatomic) IBOutlet UILabel *budgetText;

@property (strong, nonatomic) IBOutlet UILabel *mileText;

@property (strong, nonatomic) IBOutlet UISegmentedControl *distanceFilterSegment;

@property (strong, nonatomic) IBOutlet UISlider*budgetSlider;

@property (strong, nonatomic) NSArray* budgetAmounts;

@property (strong, nonatomic) NSDictionary* currentFilterCriteria_Labels;

@property (nonatomic, copy) NSString* (^budgetFilterBlock)();

-(NSDictionary*) getCurrentSearchCriteria;

-(NSDictionary*)getCurrentSearchCriteriaWithSurrondingZipcodes:(NSArray*) zipcodes;

- (IBAction)distanceFilterSegement_Action:(id)sender;

- (IBAction)startPressed:(UIButton *)sender;

- (IBAction)dragStarted:(id)sender;

- (IBAction)dragged:(id)sender;

- (IBAction)dragEnded:(id)sender;

-(void)configureBlocks;

-(void)updateSearchLables:(UILablesUpdated)completionHandler;

-(void)presentMapView;

-(void)toggleButtons;

-(void) dismissView;

-(void)reloadDealResultsReturnCount:(NSDictionary *)searchCriteria;

-(void)fetchSurroundingZipcodes:(NSDictionary*)criteria;

@end
