//
//  PSAllDealsTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSAllDealsTableViewController.h"
#import "AppDelegate.h"
#import "Deal.h"
#import "DealViewModel.h"
#import "DealDetailViewController.h"
#import "DealMapAnnotation.h"
#import "DrawerViewController.h"
#import "FilterViewController.h"
#import "DealTableViewCell.h"
#import "TransitionToFilterViewController.h"
#import "DealDetailedAnimationController.h"
#import "DismissDetailedAnimationController.h"
#import "LoadingLocalDealsViewController.h"
#import "PSEditZipcodeOfflineTableViewController.h"
#import "UIImageView+AFNetworking.h"


#define SEGUE_ALL_CURRENT_DEAL_TO_EDIT_ZIPCODE_OFFLINE_CONTROLLER @"pushToEditZipcodeOfflineViewController"
#define SEGUE_ALL_CUURENT_DEAL_TO_DEAL_DETAIL_CONTROLLER @"pushToDetailView"
#define UNWIND_TO_HOME @"unwindToHome"
#define LOADING_PAGE_VIEW_CONTROLLER @"LoadingLocalDealsViewController"
#define DEFAULT_NO_DEALS_TEXT @"Just stay in and watch a movie. "
#define kDefaultEventEndNotification @"EventEndNotification"

#define SLIDE_TIMING .42
#define PANEL_WIDTH .15

#define MENU_ICON_IMAGE @"menu_icon.png"
#define PLACE_HOLDER_IMAGE @"Cell_ImagePlaceholder.jpg"
#define FILTER_ICON_IMAGE @"empty_filter_app_icon_unselected.png"

#define PERCENTAGE_CELL_HEIGHT 0.15
#define customRowCount 1

@interface PSAllDealsTableViewController ()<LoadingPageDelegate, AccountManagerDelegate, DatabaseManagerDelegate, UIViewControllerTransitioningDelegate, DealDelegate>

typedef NS_ENUM(NSInteger, UICurrentState) {
    CLEAR = 0,
    BUSY = 1,
};

typedef void(^menuDisplayCompletion)(BOOL finished);
typedef void(^dimmerDisplayCompletion)(BOOL finished);

@property (strong, nonatomic) FilterViewController* filterView;
@property (strong, nonatomic) NSMutableDictionary* imageDownloadInProgress;
@property (strong, nonatomic) UIImage* placeholderImage;
@property (strong, nonatomic) NSMutableArray* dealTimers;
@property (strong, nonatomic) TransitionToFilterViewController* transitionToFilterController;
@property (strong, nonatomic) DealDetailedAnimationController* transitionToDetailController;
@property (strong, nonatomic) DismissDetailedAnimationController* dismissTransitionFromDetailController;
@end

@implementation PSAllDealsTableViewController
{
    Deal* selectedDeal;
    dispatch_queue_t backgroundQueue;
    NSInteger currentState;

}

static NSString* const reuseIdentifier = @"Cell";
static NSString* const emptyCellIdentifier = @"holderCell";

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (!self) return nil;
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.dealsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.transitionToFilterController = [[TransitionToFilterViewController alloc] init];
    
    self.transitionToDetailController = [[DealDetailedAnimationController alloc] init];
    
    self.dismissTransitionFromDetailController = [[DismissDetailedAnimationController alloc] init];
    
    self.filterView = [[FilterViewController alloc] init];

    self.drawer = [[DrawerViewController alloc] init];
//
//    [self.drawer setShowsShadow:YES];
//
//    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//
//    appDelegate.window.rootViewController = nil;
//
//    appDelegate.window.rootViewController = self.drawer;
//
//    [self.drawer configureCenterViewController:self.navigationController leftDrawerViewController:nil rightDrawerViewController:self.filterView];
    
    self.imageDownloadInProgress = [NSMutableDictionary dictionary];
    
    [self.dealsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:emptyCellIdentifier];
    
    if (!self.backgroundDimmer) {
        [self constructBackgroundDimmer];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    
    self.refreshControl.tintColor = [UIColor blackColor];
    
    [self.refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
    
    [self.dealsTableView setScrollEnabled:YES];
    
    [self constructEventUpdateButton];
    
    [self.view addSubview:self.eventUpdatesButton];
    
    [self.view bringSubviewToFront:self.eventUpdatesButton];
    
    UIBarButtonItem* rightFilterBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:FILTER_ICON_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(FilterButtonPressed:)];
    
    [self.navigationItem setRightBarButtonItem:rightFilterBtn];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.eventUpdatesButton setHidden:YES];
    
    [self.navigationController setNavigationBarHidden:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertOfNewEvents) name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealEnded:) name:kDefaultEventEndNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDefaultEventEndNotification object:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

#pragma mark -
#pragma mark - Construct Methods
-(void)constructBackgroundDimmer
{
    UIView* newView = [[UIView alloc] initWithFrame:CGRectZero];
    
    newView.backgroundColor = [UIColor blackColor];
    
    newView.alpha = 0.5;
    
    self.backgroundDimmer = newView;
}

-(void)constructEventUpdateButton
{
    if (!self.eventUpdatesButton) {
        
        CGFloat width = (self.view.frame.size.width / 2.5);
        
        CGFloat height = (self.view.frame.size.height / 15);
        
        CGFloat xPosition = (self.view.center.x - (width / 2));
        
        CGRect tmpBtnFrame = CGRectMake(xPosition, 0, width, height);
        
        CGRect btnFrame = CGRectOffset(tmpBtnFrame, 0, 10);
        
        self.eventUpdatesButton = [[UIButton alloc] initWithFrame:btnFrame];
        
        [self.eventUpdatesButton setTitle:@"New Events added" forState:UIControlStateNormal];
        
        self.eventUpdatesButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        
        self.eventUpdatesButton.layer.cornerRadius = 15.0f;
        
        self.eventUpdatesButton.layer.shadowOpacity = 0.9f;
        
        self.eventUpdatesButton.layer.shadowOffset = CGSizeMake(5.0f, 10.0f);
        
        UIColor* color = [UIColor colorWithRed:(float)80/255
                                         green:(float)141/255
                                          blue:(float)234/255
                                         alpha:(float)1];
        
        [self.eventUpdatesButton setBackgroundColor:color];
        
        [self.eventUpdatesButton addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventPrimaryActionTriggered];
        
    }
    
    
}

#pragma mark -
#pragma mark - Deal Loading Methods
#warning Needs error handling
-(void)refreshDeals
{
    if (self.refreshControl) {
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM d, h:mm a";
        NSString* title = [NSString stringWithFormat:@"Last update %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary* attrsDictionary = @{NSForegroundColorAttributeName: [UIColor blackColor]};
        
        NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        
        self.refreshControl.attributedTitle = attrTitle;
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(self.refreshControl){
            [self.refreshControl endRefreshing];
        }
        
        [self loadDeals];
        
        [self.view layoutIfNeeded];
    });
    
}

-(void)loadDeals
{
    [self.dealTimers removeAllObjects];
    
    [self.dealsTableView reloadData];
    
    //[self.dealsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}


#pragma mark -
#pragma mark - Image Handling Methods
-(void)startImageDownloadForDeal:(Deal*)deal forIndexPath:(NSIndexPath*) indexPath andTableCell:(DealTableViewCell*)cell
{
    DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];
    
    (dbManager).delegate = self;
    
    __block Deal* fetchingImageForDeal = (self.imageDownloadInProgress)[indexPath];
    
    if (fetchingImageForDeal == nil) {
        
        (self.imageDownloadInProgress)[indexPath] = deal;
        
        NSLog(@"CELL %@", cell.dealImage);
        
        [dbManager managerStartDownloadImageFromURL:deal.imgStateObject.imagePath forObject:deal forIndexPath:indexPath imageView:cell.dealImage addCompletion:nil];
        
    }
}


-(void)loadOnScreenDealImages
{
    DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];

    if ([dbManager managerGetSavedDeals].count > 0) {
        
        PSAllDealsTableViewController* __weak weakSelf = self;
        
        NSArray* visibleOnScreenDeals = (weakSelf.dealsTableView).visibleCells;
        
        for (DealTableViewCell* visibleCell in visibleOnScreenDeals) {
            
            if(visibleCell.dealImage.image == nil){
                
                NSIndexPath* index = [self.dealsTableView indexPathForCell:visibleCell];
                
                Deal* visibleDeal = [dbManager managerGetSavedDeals][index.row];
                
                [weakSelf startImageDownloadForDeal:visibleDeal forIndexPath:index andTableCell:visibleCell];
                
                
            }
            
            
            
        } // End of visible cell for loop
    
    } // End of deal count if statement
}

-(void)terminateDownloadingImages
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    [databaseManager managerCancelDownloads:^(BOOL success) {
        
        [self.imageDownloadInProgress removeAllObjects];
        
    }];
}


#pragma mark -
#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    NSArray* deals = [NSArray arrayWithArray:[databaseManager managerGetSavedDeals]];
    
    if (deals && deals.count >= 1) {
        return 1;
    }
    
    UILabel* messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = DEFAULT_NO_DEALS_TEXT;
    
    messageLabel.textColor = [UIColor blackColor];
    
    messageLabel.numberOfLines = 0;
    
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    
    [messageLabel sizeToFit];
    
    self.dealsTableView.backgroundView = messageLabel;
    
    self.dealsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    if ([databaseManager managerGetSavedDeals] == nil) {
        return customRowCount;
    }
    
    NSUInteger totalCount = [databaseManager managerGetSavedDeals].count;
    
    if (totalCount < 1)
    {
        return 0;
    }
    else
        return totalCount;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DealTableViewCell* dealCell = (DealTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];
    //Deal* deal = [dbManager managerGetSavedDeals][indexPath.row];
    //CFTimeInterval startTime = CACurrentMediaTime();
    
    dealCell.tag = indexPath.row;
    
    return dealCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];

    DealTableViewCell* dealCell = (DealTableViewCell*) cell;
    
    Deal* deal = [dbManager managerGetSavedDeals][indexPath.row];
    
    dealCell.dealDescription.text = deal.dealDescription;
    
    if(deal.budget <= 0) dealCell.budgetLbl.text = [NSString stringWithFormat:@"Free"];
    else if(deal.budget > 0 && deal.budget < 1) dealCell.budgetLbl.text = [NSString stringWithFormat:@"Under a dollar"];
    else{
        
        NSInteger budgetInteger = ceil(deal.budget);
        
        dealCell.budgetLbl.text = [NSString stringWithFormat:@"Under $%li", (long)budgetInteger];
    }
    
    [dealCell.dealImage setImage:[UIImage imageNamed:PLACE_HOLDER_IMAGE]];
    
    dispatch_queue_t backgroundToken = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(backgroundToken, ^{
        
        [self startImageDownloadForDeal:deal forIndexPath:indexPath andTableCell:dealCell];
        
    });
    
    if ([dealCell.dealTimer.text isEqualToString:NSLocalizedString(@"TIMER_LABEL_DEFAULT_TEXT", nil)]) {
        
        dealCell.dealTimer = [deal generateCountDownEndDate:dealCell.dealTimer];
        
    }
    
        
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DealTableViewCell* dealCell = (DealTableViewCell*) cell;
    
    if (dealCell) {
        [dealCell endAnimationLabel];
    }
    
}

 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    NSArray* deals = [NSArray arrayWithArray:[databaseManager managerGetSavedDeals]];
    
    CGRect cellPosition = [tableView rectForRowAtIndexPath: indexPath];
    CGRect positionInSuperview = [tableView convertRect:cellPosition toView:tableView.superview];
    
    selectedDeal = deals[indexPath.item];
    
    [selectedDeal setOriginalPosition:positionInSuperview];
    
    [self performSegueWithIdentifier:SEGUE_ALL_CUURENT_DEAL_TO_DEAL_DETAIL_CONTROLLER sender:self];
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark - Filter View Methods
-(IBAction)FilterButtonPressed:(id)sender
{
    DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];
    
    NSArray* deals = [dbManager managerGetSavedDeals];
    
    if(deals) self.filterView.dealsDisplayed = deals;
    else self.filterView.dealsDisplayed = nil;
    
    self.filterView.transitioningDelegate = self;
    
    //[self.filterView setDelegate:self];
    
    //[self.navigationController pushViewController:self.filterView animated:YES];
}

#pragma mark -
#pragma mark - Navigation Methods
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController*)presenting sourceController:(UIViewController *)source
{
    if([presenting isKindOfClass:[DealDetailViewController class]])
    {
        return self.transitionToDetailController;
    }
    else return nil;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if([dismissed isKindOfClass:[DealDetailViewController class]])
    {
        return self.dismissTransitionFromDetailController;
    }
    else return nil;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:SEGUE_ALL_CUURENT_DEAL_TO_DEAL_DETAIL_CONTROLLER]) {
        
        DealDetailViewController* ACDDVC = (DealDetailViewController*) segue.destinationViewController;
        
        ACDDVC.transitioningDelegate = self;
        
        [ACDDVC setOriginalPosition:[selectedDeal getOriginalPosition]];

        [ACDDVC setDealSelected:selectedDeal];
        
    }
    else if ([segue.identifier
              
        isEqualToString:SEGUE_ALL_CURRENT_DEAL_TO_EDIT_ZIPCODE_OFFLINE_CONTROLLER]) {

        LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
        
        NSString* zipcode = [locationManager getCurrentZipcode];
        
        PSEditZipcodeOfflineTableViewController* EZCOD = (PSEditZipcodeOfflineTableViewController*) segue.destinationViewController;
        
        EZCOD.currentZipcode = zipcode;
    }
}


// Method needed to indicate view controller can accept unwind actions
-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    
    if ([self respondsToSelector:action]) {
        
        NSString* viewID = fromViewController.restorationIdentifier;
        
        if ([viewID isEqualToString:@"DealsDetailViewController"]) {
            return YES;
        }
    }

    
    return NO;
}

-(void)returned:(UIStoryboardSegue *)segue
{
    
}


#pragma mark -
#pragma mark - Database Delegate Methods
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath*)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.imageDownloadInProgress removeObjectForKey:indexPath];

        NSArray* nodes = self.dealsTableView.visibleCells;

        DealTableViewCell* cell = (DealTableViewCell*) [self.dealsTableView cellForRowAtIndexPath:indexPath];
        
        
        if([nodes containsObject:cell])
        {
            [cell.imageLoadingActivityIndicator stopAnimating];
            cell.dealImage.image = image;
        }
         
        
    });
    
}

#pragma mark -
#pragma mark - Scroll View Delegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self loadOnScreenDealImages];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadOnScreenDealImages];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.eventUpdatesButton.isHidden == NO)
    {
        CGRect frame = self.eventUpdatesButton.frame;
        
        CGRect newBtnFrameOffset = CGRectOffset(scrollView.bounds, 0, 5);
        
        CGRect newFrame = CGRectMake(frame.origin.x, newBtnFrameOffset.origin.y, frame.size.width, frame.size.height);
        
        [self.eventUpdatesButton setFrame:newFrame];
    }
    
    
}

#pragma mark -
#pragma mark - Loading Page Delegate
-(void)loadingPageDismissed
{
    [self.loadingPage dismiss];
    
    self.loadingPage = nil;
}

-(void)budgetHasFinished
{
    BudgetManager* budgetManager = [BudgetManager sharedBudgetManager];
    
    NSString* currentBudget = [NSString stringWithString:[budgetManager retreieveBudget]];
    
    (self.budgetButton).title = currentBudget;
}

-(void)dealEnded:(NSNotification*)notification
{
    
    if (!notification) return;
    
    dispatch_queue_t backgroundToken = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

    DatabaseManager* dbManager = [DatabaseManager sharedDatabaseManager];
    
    // Background Thread Queue
    dispatch_async(backgroundToken, ^{
        
        NSArray* deals = [NSArray arrayWithArray:[dbManager managerGetSavedDeals]];
        
        Deal* endedDeal = (Deal*) notification.object;
        
        NSInteger indexRow = -1;
        
        for (Deal* deal in deals) {
            if ([deal isEqual:endedDeal]) {
                indexRow = [deals indexOfObject:deal];
            }
        }
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DealTableViewCell* cell = [self.dealsTableView cellForRowAtIndexPath:indexPath];
            
            if(cell){
                
                [self.dealsTableView beginUpdates];
                cell.dealTimer = [endedDeal animateCountdownEndDate:cell.dealTimer];
                [cell animateLabel];
                [self.dealsTableView endUpdates];
                
            }
        });
        
    }); // end background thread
}

#pragma mark -
#pragma mark - Notification Methods
-(void)alertOfNewEvents
{
    if(self.eventUpdatesButton.hidden == YES)
    {
        [self.eventUpdatesButton setHidden:NO];
    }
}

#pragma mark -
#pragma mark - Memory Warning Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDefaultEventEndNotification object:nil];
                                                                                                             
    // terminate all pending image downloads
    [self terminateDownloadingImages];
}

@end
