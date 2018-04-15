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
-(void) dismissView;
@end
@interface BudgetPickerViewController : UIViewController

@property (nonatomic, copy) NSString* (^budgetFilterBlock)(void);

@property (nonatomic, assign) id<BudgetPickerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *viewResultsButton;

@property (strong, nonatomic) IBOutlet UILabel *budgetText;

@property (strong, nonatomic) IBOutlet UILabel *mileText;

@property (strong, nonatomic) IBOutlet UISlider* budgetSlider;

@property (strong, nonatomic) IBOutlet UISlider* distanceSlider;

@property (strong, nonatomic) IBOutlet UILabel* lbl_DistanceMin;

@property (strong, nonatomic) IBOutlet UILabel* lbl_DistanceMax;

@property (strong, nonatomic) IBOutlet UILabel* lbl_BudgetMin;

@property (strong, nonatomic) IBOutlet UILabel* lbl_BudgetMax;

@property (strong, nonatomic) NSArray* budgetAmounts;

@property (strong, nonatomic) NSArray* mapAnnotations;

+(void) setNavigationBar:(UINavigationBar*)bar;

- (IBAction)startPressed:(UIButton *)sender;

- (IBAction)dragStarted:(id)sender;

- (IBAction)dragged:(id)sender;

- (IBAction)dragEnded:(id)sender;

-(void)configureBlocks;

-(void)updateLabels;

-(void)updateViewLabels:(NSDictionary*)searchCriteria addCompletion:(UILablesUpdated)completionHandler;

-(void)toggleButtons;

-(void) dismissView;

-(void)reloadDealResultsReturnCount:(NSDictionary *)searchCriteria;

@end
