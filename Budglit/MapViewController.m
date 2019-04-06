//
//  MapViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "FilterViewController.h"
#import "LoginPageViewController.h"
#import "PSAllDealsTableViewController.h"
#import "MapToListAnimationController.h"
#import "DismissMapToListAnimationController.h"


static double USE_CURRENT_RADIUS = -1;

@interface MapViewController()<DrawerControllerDelegate, DatabaseManagerDelegate, FilterDelegate, LoginPageDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL hasAppearedOnce;
    BOOL networkErrorStatusLinkHidden;
    BOOL updateEventsBtnHidden;
}

@property (strong, nonatomic) MapToListAnimationController* transitionController;
@property (strong, nonatomic) DismissMapToListAnimationController* dismissTransitionController;
@property (strong, nonatomic) UIView* annotationCalloutView;
@property (strong, nonatomic) FilterViewController* filterView;

@end

@implementation MapViewController

+(CGFloat) annotationPaddingPercent {return 0.20f;}
+(CGFloat) calloutViewHeightPercent {return 0.80f;}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.transitionController = [[MapToListAnimationController alloc] init];
    self.dismissTransitionController = [[DismissMapToListAnimationController alloc] init];
    self.filterView = [[FilterViewController alloc] init];
    
    self.viewModel = [[MapViewModel alloc] init];
    
    [self.viewModel setUpdateEventsBtn:self.updateEventsBtn];


    hasAppearedOnce = NO;
    networkErrorStatusLinkHidden = YES;
    updateEventsBtnHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertOfNewEvents) name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertOfNewEvents) name:NSLocalizedString(@"HOST_BACK_ONLINE_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertOfNewEvents) name:NSLocalizedString(@"HOST_OFFLINE_NOTIFICATION", nil) object:nil];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.updateEventsBtn setHidden:YES];
    [self.lbl_NetworkConnectivityIssue setHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    if(!self.mapView.userLocationVisible){
        
        LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
        
        if (!currentLocation) currentLocation = [locationManager getCurrentLocation];
        
    }
    
    [super.view layoutIfNeeded];

    databaseManager.delegate = self;
    
    if (hasAppearedOnce == NO) {
        
        CLLocationDistance radius = [self.viewModel getRadius];

        [self centerMapOnLocation:currentLocation isUserLocation:NO AndRadius:radius animate:NO addCompletion:^(BOOL success){
            
            [self.view layoutIfNeeded];

            if (success) {
                
                [self reloadDealsShouldFetchDeals:YES shouldAnimate:YES shouldClearDeals:YES AddCompletion:^(BOOL reloadSuccess) {
                    
                    if(reloadSuccess){
                        
                        [self.mapView layoutIfNeeded];
                        
                        hasAppearedOnce = YES;
                        
                    }
                    
                }];
            
            } // If center map location is success
            
        }];
        
    } // If View has not appeared once

}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"HOST_BACK_ONLINE_NOTIFICATION", nil) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"HOST_OFFLINE_NOTIFICATION", nil) object:nil];
    
    [self.mapView setDelegate:nil];
    
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    [databaseManager setDelegate:nil];
}

-(void)toggleNetworkConnectionStatusLbl
{
    
    if(networkErrorStatusLinkHidden == YES)
    {
        
        [UIView animateWithDuration:1.0 animations:^{

            [self.lbl_NetworkConnectivityIssue setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            
            if(finished == YES) networkErrorStatusLinkHidden = NO;
            
        }];
        
        
    }
    else
    {
        [UIView animateWithDuration:1.0 animations:^{

            [self.lbl_NetworkConnectivityIssue setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            
            if(finished == YES) networkErrorStatusLinkHidden = YES;
            
        }];
    }
}

-(void)toggleUpdatedEventsButton
{
    
    if(updateEventsBtnHidden == YES)
    {
        
        [self.updateEventsBtn setHidden:NO];
        
        updateEventsBtnHidden = NO;
        
    }
    else
    {
        [self.updateEventsBtn setHidden:YES];
        
        updateEventsBtnHidden = YES;

    }
    
}

-(void)alertOfNewEvents
{
    if(updateEventsBtnHidden == YES)
    {
        [self toggleUpdatedEventsButton];
    }
}

-(void)toggleAlertOfConnectivityIssues:(BOOL)toggleOn
{
    NSTimer* networkErrorTimerFlash;
    
    if([networkErrorTimerFlash isValid]) [networkErrorTimerFlash invalidate];
    
    if(toggleOn){
        
        [self.lbl_NetworkConnectivityIssue setHidden:NO];
        
        networkErrorTimerFlash = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.5) target:self selector:@selector(toggleNetworkConnectionStatusLbl) userInfo:nil repeats:YES];
        
        [networkErrorTimerFlash fire];
        
    }
    else{
        
        [networkErrorTimerFlash invalidate];
        
        [self.lbl_NetworkConnectivityIssue setHidden:YES];
        
    }
}

#pragma mark -
#pragma mark - Interface User Interaction
- (IBAction)menuBtnPressed:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    [appDelegate.drawerController slideDrawerSide:MMDrawerSideRight Animated:YES];
    
    [appDelegate.drawerController setDelegate:self];
    
}

- (IBAction)filterBtnPressed:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSMutableArray* displayedAnnotations = [[self.mapView annotations] mutableCopy];
    
    [displayedAnnotations removeObject:self.mapView.userLocation];
    
    for (int count = 0; count < displayedAnnotations.count; count++){
        
        if(![[self.mapView viewForAnnotation:displayedAnnotations[count]] isHidden]){
            displayedAnnotations[count] = (DealMapAnnotation*) displayedAnnotations[count];
            
        }
        else [displayedAnnotations removeObjectAtIndex:count];
    }
    
    NSArray* deals = [displayedAnnotations valueForKeyPath:@"@unionOfObjects.parentDeal"];
    
    if(deals) self.filterView.dealsDisplayed = deals;
    else self.filterView.dealsDisplayed = nil;
    
    [appDelegate.drawerController setLeftDrawerViewController:self.filterView];

    [self.filterView setDelegate:self];

    [appDelegate.drawerController slideDrawerSide:MMDrawerSideLeft Animated:YES];
    
}

-(IBAction)updateEventsBtnWasDragged:(id)sender withEvent:(UIEvent*)event
{

}

-(IBAction)updateEventsBtnPressed:(id)sender
{
    
    if([sender isMemberOfClass:[UIButton class]]){

        [self reloadDealsShouldFetchDeals:YES shouldAnimate:YES shouldClearDeals:NO AddCompletion:^(BOOL reloadSuccess) {
            
            if(reloadSuccess){
                
                [self.mapView layoutIfNeeded];
                
                hasAppearedOnce = YES;
                
                [self toggleUpdatedEventsButton];
                
            }
            
        }];
    }
    
}

-(CGRect)initialCalloutViewFrameForView:(UIView*)view
{
    CGRect parentViewFrame = self.view.bounds;
    
    CGFloat estimatedWidth = 1.00 * parentViewFrame.size.width;
    
    CGRect startFrame = CGRectMake(0, view.frame.origin.y, estimatedWidth, 0);
    
    return startFrame;
}

- (IBAction)currentLocationBtnPressed:(UIButton *)sender
{
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    CLLocationDistance radius = [self.viewModel getRadius];
    
    [self centerMapOnLocation:currentLocation isUserLocation:YES AndRadius:radius animate:YES addCompletion:nil];
}

#pragma mark -
#pragma mark - Deal Methods
-(void)reloadDealsShouldFetchDeals:(BOOL)shouldFetch shouldAnimate:(BOOL)animate shouldClearDeals:(BOOL)shouldClear AddCompletion:(generalBlockResponse) completionHandler;
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    (databaseManager).delegate = self;
    
    if(shouldFetch){
        
        NSDictionary* criteria = [databaseManager managerGetUsersCurrentCriteria];

        [databaseManager managerFetchDeals:criteria shouldClearCurrentDeals:shouldClear addCompletionBlock:^(id response) {

            if([response isKindOfClass:[NSError class]]){
                
                UIAlertController* dealsAlert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Seems to be some connectivity issues" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    
                    
                }];
                
                [dealsAlert addAction:retryAction];
                [dealsAlert addAction:cancelAction];
                
                [self presentViewController:dealsAlert animated:YES completion:nil];
                
                
                
            }
            else if([response isKindOfClass:[NSArray class]]){
                
                NSArray* deals = (NSArray*) response;
                
                if(deals && deals.count > 1){
                    
                    [self plotDealsOnMap:deals Animated:animate addCompletion:^(BOOL dealsPlotted) {
                        
                        [self.view layoutIfNeeded];
                        completionHandler(dealsPlotted);
                        
                    }];
                    
                }
                else if (deals.count == 1){
                    
                    Deal* deal = [deals firstObject];
                    
                    if(deal){

                        [self plotDealsOnMap:[NSArray arrayWithObject:deal] Animated:animate addCompletion:^(BOOL success) {
                            
                            [self.view layoutIfNeeded];
                            completionHandler(success);
                            
                        }];
                        
                    }
                    
                }

                
            } // End of if response is array
            else if ([response isKindOfClass:[NSNumber class]]){
                
                NSNumber* value = (NSNumber*)response;
                BOOL boolValue = [value boolValue];
                
                if(boolValue == YES){
                    
                    NSArray* deals = [databaseManager managerGetSavedDeals];
                    
                    if(deals && deals.count > 1){
                        
                        [self plotDealsOnMap:deals Animated:animate addCompletion:^(BOOL dealsPlotted){
                            
                            [self.view layoutIfNeeded];
                            completionHandler(dealsPlotted);
                            
                        }];
                        
                    }
                    else if (deals.count == 1){
                        
                        Deal* deal = [deals firstObject];
                        
                        if(deal){
                            
                            [self plotDealsOnMap:[NSArray arrayWithObject:deal] Animated:animate addCompletion:^(BOOL success) {
                                
                                [self.view layoutIfNeeded];
                                completionHandler(success);
                                
                            }];
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
        }];
        
    }
    else{
        
    }

}

#pragma mark -
#pragma mark - Gesture Methods
-(void)tapGestureRecognized:(UIGestureRecognizer*)gesture
{
    [self.annotationCalloutView removeFromSuperview];
    
    [self.backgroundScreen removeFromSuperview];
    
    [self.view layoutIfNeeded];
}

-(IBAction)swipeView:(UISwipeGestureRecognizer*)sender
{
    UIView* snapshotBtn = [self.updateEventsBtn snapshotViewAfterScreenUpdates:NO];
    
    [snapshotBtn setFrame:self.updateEventsBtn.frame];
    
    snapshotBtn.layer.cornerRadius = 5.0f;
    snapshotBtn.layer.shadowOpacity = 0.7f;
    snapshotBtn.layer.shadowOffset = CGSizeMake(5.0f, 10.0f);
    
    [self.mapView addSubview:snapshotBtn];
    
    [UIView animateWithDuration:0.6f animations:^{
        
        [self toggleUpdatedEventsButton];
        
        
        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            
            snapshotBtn.frame = CGRectMake(0 - (self.updateEventsBtn.frame.size.width + 20), self.updateEventsBtn.frame.origin.y, self.updateEventsBtn.frame.size.width, self.updateEventsBtn.frame.size.height);
            
        }
        else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            
            snapshotBtn.frame = CGRectMake(self.view.superview.frame.size.width, self.updateEventsBtn.frame.origin.y, self.updateEventsBtn.frame.size.width, self.updateEventsBtn.frame.size.height);
            
        }
        
    } completion:^(BOOL finished) {
        
        if(finished){
            [snapshotBtn removeFromSuperview];
            [self.mapView layoutIfNeeded];
        }
        
    }];
    
}

#pragma mark -
#pragma mark - Map Methods
-(void)clearMap
{
    [self clearMapRemoveUserLocation:YES];
}

-(void)scanNewRegion:(MKCoordinateRegion*)region addCompletion:(generalBlockResponse)completionHandler
{
    if(!region) completionHandler(NO);
    
    
}

-(void)clearMapRemoveUserLocation:(BOOL)remove
{
    NSArray* annotations = self.mapView.annotations;
    
    if(remove) annotations = [self annotationsFilterOutUserLocation:self.mapView.annotations];
    
    [self.mapView removeAnnotations:annotations];
}

-(NSArray*)annotationsFilterOutUserLocation:(NSArray*)list
{
    if(!list) return nil;
    
    if(list.count < 1) return list;
    
    NSMutableArray* mutableCopy = list.mutableCopy;
    
    if (mutableCopy.count > 0) {
        
        id usrLocation = [self.mapView userLocation];
        
        if (usrLocation != nil) [mutableCopy removeObject:usrLocation];
    }
    
    return list.copy;
}

-(void)centerMapOnLocation:(CLLocation *)location isUserLocation:(BOOL)isUser AndRadius:(CLLocationDistance)radius animate:(BOOL)animated addCompletion:(generalBlockResponse)completionHandler
{
    if(!location) return;
    
    if(isUser)
    {
        [self.mapView setCenterCoordinate:location.coordinate animated:animated];
        
        MKCoordinateRegion region = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius)];

        [UIView animateWithDuration:0.5 animations:^{
            
            [self.mapView setRegion:region];
            
        } completion:^(BOOL finished) {
            [self.mapView layoutIfNeeded];
            if(completionHandler) completionHandler(finished);
        }];
    }
    else
    {
        if(radius == USE_CURRENT_RADIUS)
        {
            
            [self.mapView setCenterCoordinate:location.coordinate animated:animated];
            
            MKCoordinateRegion originalRegion = [self.mapView regionThatFits:MKCoordinateRegionMake(location.coordinate, self.mapView.region.span)];
            
            CLLocationCoordinate2D newCoordinates = CLLocationCoordinate2DMake(originalRegion.center.latitude + (originalRegion.span.latitudeDelta / 2.0), originalRegion.center.longitude);
            
            MKCoordinateRegion newRegion = MKCoordinateRegionMake(newCoordinates, originalRegion.span);
            
            [UIView animateWithDuration:0.5 animations:^{
                
                [self.mapView setRegion:newRegion];
                
            } completion:^(BOOL finished) {
                
                [self.mapView layoutIfNeeded];
                
                if(completionHandler) completionHandler(YES);
            }];
            
        }
        else{
            
            MKCoordinateRegion coordinateRegion =  MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
            
            [self.mapView setRegion:coordinateRegion animated:animated];
            [self.mapView layoutIfNeeded];
            
            if(completionHandler) completionHandler(YES);
        }
    }

}

-(void)displayAllAnnotationsAddCompletion:(generalBlockResponse)completionHandler
{
    NSArray* annotations = [self.mapView annotations];
    
    if(!annotations) completionHandler(NO);
    else{
        
        for (DealMapAnnotation* annotation in annotations) {
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
        
        if(completionHandler) completionHandler(YES);
        
    }
}

-(void)plotDealsOnMap:(NSArray *)deals Animated:(BOOL)animate addCompletion:(generalBlockResponse)completionHandler
{
    if(!deals || deals.count < 1) return;
 
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    NSArray* addressList = [databaseManager managerExtractAddressesFromDeals:deals];
    
    [databaseManager managerFetchGeocodeForAddresses:addressList additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        NSArray* addressInfoList = (NSArray*) response;
        
        [databaseManager managerSaveStandardizedAddressesForDeals:addressInfoList];
        
        NSArray* annotations = [databaseManager managerCreateMapAnnotationsForDeals:deals];
        
        NSLog(@"%@", addressInfoList);
        
        if(!annotations) completionHandler(NO);
        else{
            [self.mapView addAnnotations:annotations];
            completionHandler(YES);
        }
        
    }]; // End of Geocode Fetching

}

-(void)fitAllAnnotations:(BOOL)shouldZoom addCompletion:(generalBlockResponse)completionHandler
{
    MKMapRect zoomRect = MKMapRectNull;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    
    for(id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        
        if(MKMapRectIsNull(zoomRect)){
            zoomRect = pointRect;
        }
        else zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    if(shouldZoom) [self.mapView setVisibleMapRect:zoomRect edgePadding:edgeInsets animated:YES];
    else [self.mapView setVisibleMapRect:zoomRect edgePadding:edgeInsets animated:NO];
    
    completionHandler(YES);
}

#pragma mark -
#pragma mark - Drawer View Controller Delegate Methods
-(void)switchViewPressed
{
    [self.navigationController setDelegate:self];
    
    [self performSegueWithIdentifier:@"seguePresentListView" sender:self];
}

#pragma mark -
#pragma mark - Filter View Delegate Methods
-(void)startButtonPressed:(NSArray*)filter
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        
        for (Deal* deal in databaseManager.managerGetSavedDeals) {
            
            NSPredicate* budgetPredicate = [NSPredicate predicateWithFormat:@"SELF.dealID LIKE %@", deal.dealID];
            
            NSArray* dealsFoundArry = [filter filteredArrayUsingPredicate:budgetPredicate];
            
            if(dealsFoundArry.count > 0) {
                
                Deal* foundDeal = [dealsFoundArry firstObject];
                if(foundDeal.annotation) [self.mapView removeAnnotation:foundDeal.annotation];
                
            }
            else {
                [self.mapView addAnnotation:deal.annotation];
            }
        }
         
        
    }];
    
}

#pragma mark -
#pragma mark - Database Manager Delegate
-(void)managerUserNotAuthenticated
{
    AccountManager* accountManager = [AccountManager sharedAccountManager];
    
    [accountManager logoutFromDomain:@"www.budglit.com" addCompletion:^(id object) {
        
        BOOL loggedOffSuccess = [accountManager checkLoggedOut:object];
        
        if(loggedOffSuccess) {
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UIViewController* home = [storyboard instantiateViewControllerWithIdentifier:NSLocalizedString(@"mainNavigationController", nil)];
            
            [self presentViewController:home animated:NO completion:nil];
            
        }
        
    }];
}

-(void)managerHostBackOnline
{
    [self toggleAlertOfConnectivityIssues:NO];
    
    
}

-(void)managerRequestFailed
{
    [self toggleAlertOfConnectivityIssues:YES];
}

#pragma mark -
#pragma mark - Map View Delegate Methods
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* returnedAnnotationView = nil;
    
    if(![annotation isKindOfClass:[MKUserLocation class]]){
        
        returnedAnnotationView = [DealMapAnnotation createViewAnnotationForMapView:mapView annotation:annotation];

    }
    
    return returnedAnnotationView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:false];
    
    CLLocation* annotationLocation = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
    
    if(![[view annotation] isKindOfClass:[MKUserLocation class]]){
        
        [self centerMapOnLocation:annotationLocation isUserLocation:NO AndRadius:USE_CURRENT_RADIUS animate:YES addCompletion:^(BOOL success) {
            
            if(success){
                
                [self.view layoutIfNeeded];
                
                [self prepareAnnotationCalloutViewForAnnotationView:view addCompletionBlock:^(BOOL hasCompleted) {
                    
                    if(hasCompleted) [self.view layoutIfNeeded];
                    
                }];
                
            }
            
        }];
        
    }
    else [self currentLocationBtnPressed:nil];

}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    if(hasAppearedOnce == YES)
    {
        //NSLog(@"------------------- REGION CHANGED ----------------------");
    }
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
     //NSLog(@"------------------- MAP LOADED ----------------------");
}

#pragma mark -
#pragma mark - Navigation Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PSAllDealsTableViewController* destinationController = (PSAllDealsTableViewController*) segue.destinationViewController;
    
    destinationController.transitioningDelegate = self;
    
}

-(void)prepareAnnotationCalloutViewForAnnotationView:(MKAnnotationView*)view addCompletionBlock:(generalBlockResponse)completionBlock
{
    if(!view){
        if(completionBlock) completionBlock(NO);
    }
    
    DealMapAnnotation* annotation = (DealMapAnnotation*) view.annotation;

    __block UIView* prepView = nil;
    
    CGRect startFrame = [self initialCalloutViewFrameForView:view];
    
    CGRect statusbar = [[UIApplication sharedApplication] statusBarFrame];
    
    CGFloat estimatedHeight = 0.88 * self.view.bounds.size.height;
    CGFloat estimatedWidth = 1.00 * self.view.bounds.size.width;
    
    CGRect prepViewFrame = CGRectMake(0, statusbar.size.height, estimatedWidth, estimatedHeight);
    
    CGRect prepViewInsetFrame = CGRectInset(prepViewFrame, 10.0f, 5.0f);
    
    prepView = [[UIView alloc] init];
    
    self.annotationCalloutView = prepView;
    
    [self.viewModel setAnnotationCalloutView:self.annotationCalloutView];
    
    [self.annotationCalloutView setFrame:startFrame];
    
    self.backgroundScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    
    [self.backgroundScreen setBackgroundColor:[UIColor blackColor]];
    
    [self.backgroundScreen setAlpha:0.0f];
    
    [self.view addSubview:self.backgroundScreen];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    
    [tapGesture setNumberOfTapsRequired:1];
    
    [tapGesture setNumberOfTouchesRequired:1];
    
    [self.backgroundScreen addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.annotationCalloutView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        
        [self.backgroundScreen setAlpha:0.6f];
        
        [self.annotationCalloutView setFrame:prepViewInsetFrame];
        
        [self.mapView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if(finished){
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            DealDetailViewController* detailedViewController = (DealDetailViewController*) [storyboard instantiateViewControllerWithIdentifier:@"DealsDetailViewController"];
  
            [detailedViewController setDealSelected:annotation.parentDeal];
            
            [self.annotationCalloutView addSubview:detailedViewController.view];
            
            [detailedViewController.view setFrame:self.annotationCalloutView.bounds];
            
            [detailedViewController.view setBounds:self.annotationCalloutView.bounds];
            
            [detailedViewController.view setNeedsLayout];
            
            detailedViewController.view.layer.cornerRadius = 5.0f;
            
            if(completionBlock) completionBlock(YES);
        }
        
    }];
    
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionController;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[PSAllDealsTableViewController class]]) return self.dismissTransitionController;
    else return self.transitionController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissTransitionController;
}


#pragma mark
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"NEW_UPDATES_NOTIFICATION", nil) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"HOST_BACK_ONLINE_NOTIFICATION", nil) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"HOST_OFFLINE_NOTIFICATION", nil) object:nil];
}
@end
