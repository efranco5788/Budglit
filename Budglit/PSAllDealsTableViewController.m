//
//  PSAllDealsTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSAllDealsTableViewController.h"
#import "DealDetailViewController.h"
#import "Deal.h"
#import "DrawerViewController.h"
#import "AppDelegate.h"
#import "LoadingLocalDealsViewController.h"
#import "AccountManager.h"
#import "BudgetManager.h"
#import "DatabaseManager.h"
#import "LocationServiceManager.h"
#import "DealTableViewCell.h"
#import "DealDetailedAnimationController.h"
#import "DismissDetailedAnimationController.h"
#import "PSEditZipcodeOfflineTableViewController.h"
#import "UINavigationController+CompletionHandler.h"
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
#define CELL_PLACEHOLDER_IMAGE @"Cell_ImagePlaceholder.jpg"

#define PERCENTAGE_CELL_HEIGHT 0.15
#define customRowCount 1

@interface PSAllDealsTableViewController ()<LoadingPageDelegate, AccountManagerDelegate, DatabaseManagerDelegate, UIViewControllerTransitioningDelegate, DealDelegate>

typedef NS_ENUM(NSInteger, UICurrentState) {
    CLEAR = 0,
    BUSY = 1,
};

typedef void(^menuDisplayCompletion)(BOOL finished);
typedef void(^dimmerDisplayCompletion)(BOOL finished);

@property (nonatomic, strong) NSMutableDictionary* imageDownloadInProgress;
@property (nonatomic, strong) UIImage* placeholderImage;
@property (nonatomic, strong) NSMutableArray* dealTimers;
@property (strong, nonatomic) DealDetailedAnimationController* transitionController;
@property (strong, nonatomic) DismissDetailedAnimationController* dismissTransitionController;
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
    
    self.transitionController = [[DealDetailedAnimationController alloc] init];
    
    self.dismissTransitionController = [[DismissDetailedAnimationController alloc] init];
    
    self.imageDownloadInProgress = [NSMutableDictionary dictionary];
    
    self.placeholderImage = [UIImage imageNamed:CELL_PLACEHOLDER_IMAGE];
    
    [self.dealsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:emptyCellIdentifier];
    
    if (!self.backgroundDimmer) {
        [self constructBackgroundDimmer];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    
    self.refreshControl.tintColor = [UIColor blackColor];
    
    [self.refreshControl addTarget:self action:@selector(refreshDeals) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.dealsTableView setScrollEnabled:YES];
    
    [self.navigationController setNavigationBarHidden:NO];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(dealEnded:) name:kDefaultEventEndNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    }
    
    CGRect frame = self.dealsTableView.frame;
    
    [self.dealsTableView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, frame.size.width, frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    
    [self.view layoutIfNeeded];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:kDefaultEventEndNotification object:nil];
}

-(void)constructBackgroundDimmer
{
    UIView* newView = [[UIView alloc] initWithFrame:CGRectZero];
    
    newView.backgroundColor = [UIColor blackColor];
    
    newView.alpha = 0.5;
    
    self.backgroundDimmer = newView;
}

#warning Needs error handling
-(void)refreshDeals
{
    //AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    //(appDelegate.databaseManager).delegate = self;
    
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
    
    /*
    [appDelegate.databaseManager fetchDeals:nil addCompletionBlock:^(BOOL success) {
        
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
        
        if(success){
            [self loadDeals];
            
        }
        else{

        }
        
    }];
     */
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
    __block Deal* fetchingImageForDeal = (self.imageDownloadInProgress)[indexPath];
    
    if (fetchingImageForDeal == nil) {
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        (appDelegate.databaseManager).delegate = self;
        
        // Background Queue Token
        backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        dispatch_async(backgroundQueue, ^{
            
            [appDelegate.databaseManager managerStartDownloadImageFromURL:deal.imgStateObject.imagePath forObject:cell forIndexPath:indexPath imageView:cell.dealImage];
            
            (self.imageDownloadInProgress)[indexPath] = deal;
            
        });
        
    }
}


-(void)loadOnScreenDealImages
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    if ([appDelegate.databaseManager managerGetSavedDeals].count > 0) {
        
        PSAllDealsTableViewController* __weak weakSelf = self;
        
        NSArray* visibleOnScreenDeals = (weakSelf.dealsTableView).visibleCells;
        
        for (DealTableViewCell* visibleCell in visibleOnScreenDeals) {
            
            NSIndexPath* index = [self.dealsTableView indexPathForCell:visibleCell];
            
            __block Deal* visibleDeal = [appDelegate.databaseManager managerGetSavedDeals][index.row];
            
            [appDelegate.databaseManager managerFetchCachedImageForKey:visibleDeal.imgStateObject.imagePath addCompletion:^(UIImage *image) {
                
                if(image){
                    [visibleCell.dealImage setImage:image];
                    [visibleCell.imageLoadingActivityIndicator stopAnimating];
                }
                else{
                    
                    // Disable any interaction if image for the deal has not loaded yet
                    //[visibleCell setUserInteractionEnabled:NO];
                    
                    [appDelegate.databaseManager managerFetchPersistentStorageCachedImageForKey:visibleDeal.imgStateObject.imagePath deal:visibleDeal addCompletion:^(UIImage *img) {
                        
                        if(img){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [visibleCell.imageLoadingActivityIndicator stopAnimating];
                                visibleCell.dealImage.image = img;
                                //[visibleCell setUserInteractionEnabled:YES];
                                
                            });
                            
                        }
                        else [weakSelf startImageDownloadForDeal:visibleDeal forIndexPath:index andTableCell:visibleCell];
                        
                    }]; // End of Persistent Storage Fetch
                }
                
            }]; // End of Memory Cache image search
            
            
        } // End of visible cell for loop
    
    } // End of deal count if statement
}

-(void)terminateDownloadingImages
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.databaseManager managerCancelDownloads:^(BOOL success) {
        
        [self.imageDownloadInProgress removeAllObjects];
        
    }];
}


#pragma mark -
#pragma mark - Account Manager Delegate
-(void)logoutSucessfully
{
    [self performSegueWithIdentifier:UNWIND_TO_HOME sender:self];
}


#pragma mark -
#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager managerGetSavedDeals]];
    
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
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if ([appDelegate.databaseManager managerGetSavedDeals] == nil) {
        return customRowCount;
    }
    
    NSUInteger totalCount = [appDelegate.databaseManager managerGetSavedDeals].count;
    
    if (totalCount < 1)
    {
        return 0;
    }
    else
        return totalCount;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    DealTableViewCell* dealCell = nil;
    
    NSUInteger nodeCount = [appDelegate.databaseManager managerGetSavedDeals].count;
    
    if (nodeCount == 0 && indexPath.row == 0) {
        
        //dealCell = (DealTableViewCell*) [self.dealsTableView dequeueReusableCellWithIdentifier:emptyCellIdentifier forIndexPath:indexPath];
        
    }
    else{
        
        dealCell = (DealTableViewCell*) [self.dealsTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if (nodeCount > 0) {

            Deal* deal = [appDelegate.databaseManager managerGetSavedDeals][indexPath.row];
            
            dealCell.dealDescription.text = deal.dealDescription;
            
        }
        
    }
    
    return dealCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSUInteger nodeCount = [appDelegate.databaseManager managerGetSavedDeals].count;
    
    if (nodeCount > 0) {
        
        if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){

        }
        
        Deal* deal = [appDelegate.databaseManager managerGetSavedDeals][indexPath.row];
        
        DealTableViewCell* dealCell = (DealTableViewCell*) cell;
        
        [appDelegate.databaseManager managerFetchCachedImageForKey:deal.imgStateObject.imagePath addCompletion:^(UIImage *image) {
            
            if (image){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    dealCell.dealImage.image = image;
                    [dealCell.imageLoadingActivityIndicator stopAnimating];
                });
                
            }
            else {
                
                //[dealCell setUserInteractionEnabled:NO]; // Disable any interaction if image for the deal has not loaded yet
                
                dealCell.dealImage.image = self.placeholderImage;
                
                [dealCell.imageLoadingActivityIndicator startAnimating];
                
                [appDelegate.databaseManager managerFetchPersistentStorageCachedImageForKey:deal.imgStateObject.imagePath deal:deal addCompletion:^(UIImage *img) {
                    
                    if(!img){
                        if (self.dealsTableView.dragging == NO && self.dealsTableView.decelerating == NO){
                            
                            if(dealCell){
                                [self startImageDownloadForDeal:deal forIndexPath:indexPath andTableCell:dealCell];
                            }
                            
                        }
                    }
                    else{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            dealCell.dealImage.image = img;
                            //[dealCell setUserInteractionEnabled:YES];
                            [dealCell.imageLoadingActivityIndicator stopAnimating];
                            
                        });
                        
                    }
                    
                    
                }]; // End of fetching image in Persistent Storage Cache
                
            }
            
        }]; // End of Fetching Image in Cache
         
         
     
        if ([dealCell.dealTimer.text isEqualToString:NSLocalizedString(@"TIMER_LABEL_DEFAULT_TEXT", nil)]) {
            dealCell.dealTimer = [deal generateCountDownEndDate:dealCell.dealTimer];
        }
        
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
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager managerGetSavedDeals]];
    
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
#pragma mark - Navigation Methods
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissTransitionController;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:SEGUE_ALL_CUURENT_DEAL_TO_DEAL_DETAIL_CONTROLLER]) {
        
        DealDetailViewController* ACDDVC = (DealDetailViewController*) segue.destinationViewController;
        
        ACDDVC.transitioningDelegate = self;
        
        [ACDDVC setOriginalPosition:[selectedDeal getOriginalPosition]];
        
        ACDDVC.venueName = selectedDeal.venueName;
        
        ACDDVC.descriptionText = selectedDeal.dealDescription;
        
        ACDDVC.addressText = [NSString stringWithFormat:@"\n%@ \n"
                              "%@, %@ %@", selectedDeal.address, selectedDeal.city, selectedDeal.state, selectedDeal.zipcode];
        
        ACDDVC.phoneText = [NSString stringWithFormat:@"\n%@", selectedDeal.phoneNumber];
        
        ACDDVC.dealSelected = selectedDeal;
        
        
    }
    else if ([segue.identifier isEqualToString:SEGUE_ALL_CURRENT_DEAL_TO_EDIT_ZIPCODE_OFFLINE_CONTROLLER]) {
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        NSString* zipcode = [appDelegate.locationManager getCurrentZipcode];
        
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
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    
    DealTableViewCell* cell = (DealTableViewCell*) [self.dealsTableView cellForRowAtIndexPath:indexPath];
    
    __block CATransition* transition = [CATransition animation];
    
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    
    if(cell){

        [cell.dealImage.layer addAnimation:transition forKey:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.dealImage.image = image;
            
            //[cell setUserInteractionEnabled:YES];
            
            [cell.imageLoadingActivityIndicator stopAnimating];
            
            [self.imageDownloadInProgress removeObjectForKey:indexPath];
            
        });
        
    }
    
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


#pragma mark -
#pragma mark - Loading Page Delegate
-(void)loadingPageDismissed
{
    [self.loadingPage dismiss];
    
    self.loadingPage = nil;
}

-(void)locationHasFinished
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if (![appDelegate.budgetManager isBudgetExists]) {
        [self.loadingPage inputBudget];
    }
    else{
        
        NSMutableDictionary* currentCriteria = [[appDelegate.databaseManager managerGetUsersCurrentCriteria] mutableCopy];
        
        NSString* currentDate = [appDelegate.databaseManager currentDate];
        
        [currentCriteria removeObjectForKey:NSLocalizedString(@"DATE_FILTER", nil)];
        
        currentCriteria[NSLocalizedString(@"DATE_FILTER", nil)] = currentDate;
        
        NSDictionary* updatedCriteria = [NSDictionary dictionaryWithDictionary:currentCriteria];
        
        [appDelegate.databaseManager managerSaveUsersCriteria:updatedCriteria];
    }
}

-(void)budgetHasFinished
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* currentBudget = [NSString stringWithString:[appDelegate.budgetManager retreieveBudget]];
    
    (self.budgetButton).title = currentBudget;
}

-(void)newDealsFetched
{
    [self loadDeals];
}

-(void)dealEnded:(NSNotification*)notification
{
    
    if (!notification) return;
    
    dispatch_queue_t backgroundToken = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    // Background Thread Queue
    dispatch_async(backgroundToken, ^{
        
        NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager managerGetSavedDeals]];
        
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
#pragma mark - Memory Warning Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
                                                                                                             
    // terminate all pending image downloads
    [self terminateDownloadingImages];
}

@end
