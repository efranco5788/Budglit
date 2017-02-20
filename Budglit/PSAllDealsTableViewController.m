//
//  PSAllDealsTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSAllDealsTableViewController.h"
#import "PSDealDetailViewController.h"
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

#define SLIDE_TIMING .42
#define PANEL_WIDTH .15

#define MENU_ICON_IMAGE @"menu_icon.png"
#define CELL_PLACEHOLDER_IMAGE @"Cell_ImagePlaceholder.jpg"

#define PERCENTAGE_CELL_HEIGHT 0.15
#define customRowCount 1

@interface PSAllDealsTableViewController ()<LoadingPageDelegate, AccountManagerDelegate, DatabaseManagerDelegate, UIViewControllerTransitioningDelegate>

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

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    //[self terminateDownloadingImages];
}

-(void)constructBackgroundDimmer
{
    UIView* newView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [newView setBackgroundColor:[UIColor blackColor]];
    
    [newView setAlpha:0.5];
    
    self.backgroundDimmer = newView;
}

-(void)refreshDeals
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager setDelegate:self];
    
    [appDelegate.databaseManager fetchDeals:nil];
}

-(void)loadDeals
{
    [self.dealTimers removeAllObjects];
    
    [self.dealsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark - Image Handling Methods
-(void) startImageDownloadForDeal:(Deal*)deal forIndexPath:(NSIndexPath*) indexPath andTableCell:(DealTableViewCell*)cell
{
    __block Deal* fetchingImageForDeal = (self.imageDownloadInProgress)[indexPath];
    
    if (fetchingImageForDeal == nil) {
        
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        [appDelegate.databaseManager setDelegate:self];
        
        NSString* url = deal.imgStateObject.imagePath;
        
        backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        // Background Thread Queue
        dispatch_async(backgroundQueue, ^{
            
            [appDelegate.databaseManager startDownloadImageFromURL:url forDeal:deal forIndexPath:indexPath imageView:cell.dealImage];
            
        });
        
        (self.imageDownloadInProgress)[indexPath] = deal;
        
    }
}

-(void)loadOnScreenDealImages
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
    if (deals.count > 0) {
        
        PSAllDealsTableViewController* __weak weakSelf = self;
        
        NSArray* visibleOnScreenDeals = [weakSelf.dealsTableView visibleCells];
        
        for (DealTableViewCell* visibleCell in visibleOnScreenDeals) {
            
            NSIndexPath* index = [self.dealsTableView indexPathForCell:visibleCell];
            
            __block Deal* visibleDeal = [deals objectAtIndex:index.row];
            
            if (![visibleDeal.imgStateObject imageExists]) {
                
                [weakSelf startImageDownloadForDeal:visibleDeal forIndexPath:index andTableCell:visibleCell];
            }
        }
    }
}

-(void)terminateDownloadingImages
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager cancelDownloads:^(BOOL success) {
        
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
#pragma mark - Database Manager Delegate
-(void)imageFetchedForDeal:(Deal *)deal forIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    // Load the images on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DealTableViewCell* dealCell = (DealTableViewCell*) [self.dealsTableView cellForRowAtIndexPath:indexPath];
        
        [dealCell.imageLoadingActivityIndicator stopAnimating];
        
        [self.imageDownloadInProgress removeObjectForKey:indexPath];
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.1f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        
        [imageView.layer addAnimation:transition forKey:nil];
        
        [imageView setImage:image];
    });
    
}

#pragma mark -
#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
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
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
    if (deals == nil) {
        return customRowCount;
    }
    
    NSUInteger totalCount = deals.count;
    
    if (totalCount < 1)
    {
        return 0;
    }
    else
        return totalCount;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
    DealTableViewCell* dealCell = nil;
    
    NSUInteger nodeCount = deals.count;
    
    if (nodeCount == 0 && indexPath.row == 0) {
        
        //dealCell = (DealTableViewCell*) [self.dealsTableView dequeueReusableCellWithIdentifier:emptyCellIdentifier forIndexPath:indexPath];
        
    }
    else{
        
        if (nodeCount > 0) {
            
            Deal* deal = [deals objectAtIndex:indexPath.row];
            
            dealCell = (DealTableViewCell*) [self.dealsTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            
            [dealCell.imageLoadingActivityIndicator startAnimating];
            
            [[dealCell dealImage] setImage:self.placeholderImage];
            
            dealCell.dealDescription.text = deal.dealDescription;
        }
        
    }
    
    return dealCell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
    NSUInteger nodeCount = deals.count;
    
    if (nodeCount > 0) {
        
        Deal* deal = [deals objectAtIndex:indexPath.row];
        
        DealTableViewCell* dealCell = (DealTableViewCell*) cell;
        
        [self startImageDownloadForDeal:deal forIndexPath:indexPath andTableCell:dealCell];
        
        if ([dealCell.dealTimer.text isEqualToString:NSLocalizedString(@"TIMER_LABEL_DEFAULT_TEXT", nil)]) {
            
            dealCell.dealTimer = [deal generateCountDownEndDate:dealCell.dealTimer];
        }        
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* deals = [NSArray arrayWithArray:[appDelegate.databaseManager currentDeals]];
    
    CGRect cellPosition = [tableView rectForRowAtIndexPath: indexPath];
    CGRect positionInSuperview = [tableView convertRect:cellPosition toView:tableView.superview];
    
    selectedDeal = [deals objectAtIndex:indexPath.item];
    
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:SEGUE_ALL_CUURENT_DEAL_TO_DEAL_DETAIL_CONTROLLER]) {
        
        PSDealDetailViewController* ACDDVC = (PSDealDetailViewController*) segue.destinationViewController;
        
        ACDDVC.transitioningDelegate = self;
        
        [ACDDVC setOriginalPosition:[selectedDeal getOriginalPosition]];
        
        ACDDVC.venueName = selectedDeal.venueName;
        
        ACDDVC.descriptionText = selectedDeal.dealDescription;
        
        ACDDVC.addressText = [NSString stringWithFormat:@"\n%@ \n"
                              "%@, %@ %@", selectedDeal.address, selectedDeal.city, selectedDeal.state, selectedDeal.zipcode];
        
        ACDDVC.phoneText = [NSString stringWithFormat:@"\n%@", selectedDeal.phoneNumber];
        
        ACDDVC.dealSelected = selectedDeal;
        
        ACDDVC.image = self.placeholderImage;
        
        if ([selectedDeal.imgStateObject imageExists]) {
            
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.databaseManager fetchImageForRequest:selectedDeal.imgStateObject.request addCompletion:^(UIImage *image) {
                
                ACDDVC.image = image;
                
            }];
            
        }
        else ACDDVC.image = self.placeholderImage;
        
        
    }
    else if ([segue.identifier isEqualToString:SEGUE_ALL_CURRENT_DEAL_TO_EDIT_ZIPCODE_OFFLINE_CONTROLLER])
    {
        AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
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
        
        if ([viewID isEqualToString:@"PSDealsDetailViewController"]) {
            return YES;
        }
    }

    
    return NO;
}

-(void)returned:(UIStoryboardSegue *)segue
{
    
}


#pragma mark -
#pragma mark - Menu View Delegate
-(void)menuBeingPresented
{
    
}

-(void)menuPresented
{
    
}

-(void)menuDismissed
{
    [self.dealsTableView setScrollEnabled:YES];
}


#pragma mark -
#pragma mark - Database Delegate
-(void)DealsDidLoad:(BOOL)result
{
    if (self.refreshControl) {
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString* title = [NSString stringWithFormat:@"Last update %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary* attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        
        self.refreshControl.attributedTitle = attrTitle;
        
        [self.refreshControl endRefreshing];
    }
    
    [self loadDeals];
}

-(void)DealsDidNotLoad
{
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
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
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if (![appDelegate.budgetManager isBudgetExists]) {
        [self.loadingPage inputBudget];
    }
    else{
        
        NSMutableDictionary* currentCriteria = [[appDelegate.databaseManager getUsersCurrentCriteria] mutableCopy];
        
        NSString* currentDate = [appDelegate.databaseManager getCurrentDate];
        
        [currentCriteria removeObjectForKey:NSLocalizedString(@"DATE_FILTER", nil)];
        
        [currentCriteria setObject:currentDate forKey:NSLocalizedString(@"DATE_FILTER", nil)];
        
        NSDictionary* updatedCriteria = [NSDictionary dictionaryWithDictionary:currentCriteria];
        
        [appDelegate.databaseManager saveUsersCriteria:updatedCriteria];
        
        [self.loadingPage reloadDeals];
    }
}

-(void)budgetHasFinished
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSString* currentBudget = [NSString stringWithString:[appDelegate.budgetManager retreieveBudget]];
    
    [self.budgetButton setTitle:currentBudget];
    
    [self.loadingPage reloadDeals];
}

-(void)newDealsFetched
{
    [self loadDeals];
}


#pragma mark -
#pragma mark - Memory Warning Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // terminate all pending image downloads
    [self terminateDownloadingImages];
}

@end
