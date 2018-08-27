//
//  MapViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "BudgetPickerViewController.h"
#import "LoginPageViewController.h"
#import "PSAllDealsTableViewController.h"
#import "MapToListAnimationController.h"
#import "DismissMapToListAnimationController.h"

static double USE_CURRENT_RADIUS = -1;

@interface MapViewController()<DrawerControllerDelegate, DatabaseManagerDelegate, BudgetPickerDelegate, LoginPageDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, MKMapViewDelegate>
{
    BOOL hasAppearedOnce;
}

@property (strong, nonatomic) MapToListAnimationController* transitionController;
@property (strong, nonatomic) DismissMapToListAnimationController* dismissTransitionController;
@property (strong, nonatomic) UIView* annotationCalloutView;
@property (strong, nonatomic) BudgetPickerViewController* budgetView;
//@property (strong, nonatomic) NSMutableArray* annotations;

@end

@implementation MapViewController

+(CGFloat) annotationPaddingPercent {return 0.20f;}
+(CGFloat) calloutViewHeightPercent {return 0.80f;}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.transitionController = [[MapToListAnimationController alloc] init];
    self.dismissTransitionController = [[DismissMapToListAnimationController alloc] init];
    self.budgetView = [[BudgetPickerViewController alloc] init];
    
    hasAppearedOnce = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [super.view setNeedsLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    if(!self.mapView.userLocationVisible) if (!currentLocation) currentLocation = [appDelegate.locationManager getCurrentLocation];
    
    if (hasAppearedOnce == NO) {
        
        NSDictionary* filter = [appDelegate.databaseManager managerGetUsersCurrentCriteria];
        
        NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
        
        double meters = (miles * 1609.34);
        
        CLLocationDistance radius = meters;

        [self centerMapOnLocation:currentLocation isUserLocation:NO AndRadius:radius animate:NO addCompletion:^(BOOL success){
            
            [self.view layoutIfNeeded];

            if (success) {
                
                [self reloadDealsShouldFetchDeals:YES AddCompletion:^(BOOL reloadSuccess) {
                    
                    if(reloadSuccess){
                        [self.mapView layoutIfNeeded];
                        hasAppearedOnce = YES;
                    }
                    
                }];
            
            } // If success

        }];
        
    }

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapView setDelegate:nil];
}

- (IBAction)menuBtnPressed:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    MMDrawerSide sideRight = MMDrawerSideRight;
    
    [appDelegate.drawerController slideDrawerSide:sideRight Animated:YES];
    
    [appDelegate.drawerController setDelegate:self];
    
}

- (IBAction)filterBtnPressed:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    //self.budgetView = (BudgetPickerViewController*) [appDelegate.drawerController leftDrawerViewController];
    
    [appDelegate.drawerController setLeftDrawerViewController:self.budgetView];

    [self.budgetView setDelegate:self];
    
    MMDrawerSide sideLeft = MMDrawerSideLeft;
    
    [appDelegate.drawerController slideDrawerSide:sideLeft Animated:YES];
    
}

-(CGRect)initialCalloutViewFrameForView:(UIView*)view
{
    CGRect parentViewFrame = self.view.bounds;
    
    CGFloat estimatedWidth = 1.00 * parentViewFrame.size.width;
    
    CGRect startFrame = CGRectMake(0, view.frame.origin.y, estimatedWidth, 0);
    
    return startFrame;
}

-(void)tapGestureRecognized:(UIGestureRecognizer*)gesture
{
    [self.annotationCalloutView removeFromSuperview];
    
    [self.view layoutIfNeeded];
    
    [self.backgroundScreen removeFromSuperview];
    
    [self.view layoutIfNeeded];
}

- (IBAction)currentLocationBtnPressed:(UIButton *)sender
{
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSDictionary* filter = [appDelegate.databaseManager managerGetUsersCurrentCriteria];
    
    NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
    
    double meters = (miles * 1609.34);
    
    CLLocationDistance radius = meters;
    
    NSLog(@"%li", (long)miles);
    
    [self centerMapOnLocation:currentLocation isUserLocation:YES AndRadius:radius animate:YES addCompletion:^(BOOL success) {
        
    }];
}

#pragma mark -
#pragma mark - Deal Methods
-(void)reloadDealsShouldFetchDeals:(BOOL)shouldFetch AddCompletion:(generalBlockResponse) completionHandler;
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    if(shouldFetch){
        
        NSDictionary* criteria = [appDelegate.databaseManager managerGetUsersCurrentCriteria];
        
        [appDelegate.databaseManager managerFetchDeals:criteria addCompletionBlock:^(id response) {
            
            if(response){
                
                NSArray* fetchedDeals = (NSArray*) response;
                
                [appDelegate.databaseManager managerResetDeals];
                
                BOOL saved = [appDelegate.databaseManager managerSaveFetchedDeals:fetchedDeals];
                
                if(saved){
                    
                    NSArray* deals = [appDelegate.databaseManager managerGetSavedDeals];
                    
                    if(deals && deals.count > 1){
                        
                        [self plotDealsOnMap:deals Animated:YES addCompletion:^(BOOL dealsPlotted) {
                            
                            [self.view layoutIfNeeded];
                            
                            completionHandler(dealsPlotted);
                            
                        }];
                        
                    }
                    else if (deals.count == 1)
                    {
                        Deal* deal = [deals objectAtIndex:0];
                        
                        [self plotDealOnMap:deal addCompletion:^(BOOL dealPlotted) {
                            completionHandler(dealPlotted);
                        }];
                    }
                    
                }
                
            } // End of if response is non-nill
            
        }];
        
    }
    else{
        
    }
    

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
            completionHandler(finished);
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
                completionHandler(YES);
            }];
            
        }
        else{
            
            MKCoordinateRegion coordinateRegion =  MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
            
            [self.mapView setRegion:coordinateRegion animated:animated];
            [self.mapView layoutIfNeeded];
            completionHandler(YES);
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
        
        completionHandler(YES);
        
    }
}

-(void)plotDealOnMap:(Deal *)deal addCompletion:(generalBlockResponse)completionHandler
{
    if(!deal) return;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* address = deal.address.copy;
    
    [appDelegate.databaseManager managerFetchGeocodeForAddress:address additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        
    }];
}

-(void)plotDealsOnMap:(NSArray *)deals
{
    [self plotDealsOnMap:deals Animated:NO addCompletion:^(BOOL success) {
        
    }];
}

-(void)plotDealsOnMap:(NSArray *)deals Animated:(BOOL)animate addCompletion:(generalBlockResponse)completionHandler
{
    if(!deals || deals.count < 1) return;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* addressList = [appDelegate.databaseManager.engine extractAddressFromDeals:deals];
    
    //__block NSMutableArray* annotations = [[NSMutableArray alloc] init];
    //self.annotations = [[NSMutableArray alloc] init];
    
    [appDelegate.databaseManager managerFetchGeocodeForAddresses:addressList additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        NSArray* addressInfoList = (NSArray*) response;
        
        NSArray* annotations = [appDelegate.databaseManager managerCreateMapAnnotationsForDeals:deals addressInfo:addressInfoList];
        
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
#pragma mark - Budget Picker View Delegate Methods
-(void)startButtonPressed:(NSArray *)filter
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSArray* filteredOutDeals = [appDelegate.databaseManager managerExtractDeals:filter fromDeals:appDelegate.databaseManager.managerGetSavedDeals];
    
    if(filteredOutDeals.count >= 1){
        
        [self displayAllAnnotationsAddCompletion:^(BOOL success) {
            
            if(success){
                
                NSMutableArray* mapAnnotations = [[self.mapView annotations] mutableCopy];
                
                for(Deal* deal in filteredOutDeals){
                    
                    for (DealMapAnnotation* annotation in mapAnnotations) {
                        
                        if([deal isEqual:annotation.dealAnnotated]){
                            [[self.mapView viewForAnnotation:annotation] setHidden:YES];
                            [mapAnnotations removeObject:annotation];
                            break;
                        }
                        
                    }
                    
                }
                
                [appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
                
            }
            
        }]; // End of display annotation method
        
    }
}

#pragma mark -
#pragma mark - Database Manager Delegate
-(void)userNotAuthenticated
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.accountManager logoutFromDomain:@"www.budglit.com" addCompletion:^(id object) {
        
        BOOL loggedOffSuccess = [appDelegate.accountManager checkLoggedOut:object];
        
        if(loggedOffSuccess) {
            
            UIViewController* loginPage = [[LoginPageViewController alloc] initWithNibName:@"LoginPageViewController" bundle:nil];
            
            //loginPage.delegate = self;
            
            loginPage.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentViewController:loginPage animated:NO completion:^{
                
            }];
            
        }
        
    }];
}

#pragma mark -
#pragma mark - Map View Delegate Methods
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* returnedAnnotationView = nil;
    
    if(![annotation isKindOfClass:[MKUserLocation class]]){
        
        returnedAnnotationView = [DealMapAnnotation createViewAnnotationForMapView:self.mapView annotation:annotation];

    }
    
    return returnedAnnotationView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self.mapView deselectAnnotation:view.annotation animated:false];
    
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
        NSLog(@"------------------- REGION CHANGED ----------------------");
    }
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
     NSLog(@"------------------- MAP LOADED ----------------------");
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
    if(!view) completionBlock(NO);
    
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
    
    [self.annotationCalloutView setAlpha:1.0];
    
    [self.annotationCalloutView setFrame:startFrame];
    
    self.annotationCalloutView.layer.cornerRadius = 5.0f;
    
    self.annotationCalloutView.layer.shadowOpacity = 0.5f;
    
    self.annotationCalloutView.layer.shadowOffset = CGSizeMake(5.0f, 10.0f);
    
    self.annotationCalloutView.backgroundColor = [UIColor whiteColor];
    
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
            
            DealDetailViewController* detailedViewController = (DealDetailViewController*) [storyboard instantiateViewControllerWithIdentifier:@"PSDealsDetailViewController"];
            
            detailedViewController.dealSelected = annotation.dealAnnotated;
            
            detailedViewController.venueName = annotation.dealAnnotated.venueName;
            
            detailedViewController.descriptionText = annotation.dealAnnotated.dealDescription;
            
            detailedViewController.addressText = [NSString stringWithFormat:@"\n%@ \n"
                                                  "%@, %@ %@", annotation.dealAnnotated.address, annotation.dealAnnotated.city, annotation.dealAnnotated.state, annotation.dealAnnotated.zipcode];
            
            detailedViewController.phoneText = [NSString stringWithFormat:@"\n%@", annotation.dealAnnotated.phoneNumber];
            
            [self.annotationCalloutView addSubview:detailedViewController.view];
            
            [detailedViewController.view setFrame:self.annotationCalloutView.bounds];
            
            detailedViewController.view.layer.cornerRadius = 5.0f;
            
            completionBlock(YES);
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
