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
#import "PSAllDealsTableViewController.h"
#import "MapToListAnimationController.h"
#import "DismissMapToListAnimationController.h"

static double USE_CURRENT_RADIUS = -1;

@interface MapViewController()<DrawerControllerDelegate, DatabaseManagerDelegate, BudgetPickerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, MKMapViewDelegate>
{
    BOOL hasAppearedOnce;
}

@property (strong, nonatomic) MapToListAnimationController* transitionController;
@property (strong, nonatomic) DismissMapToListAnimationController* dismissTransitionController;

@property (strong, nonatomic) UIView* annotationCalloutView;

@end

@implementation MapViewController

+(CGFloat) annotationPaddingPercent {return 0.20f;}
+(CGFloat) calloutViewHeightPercent {return 0.80f;}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.transitionController = [[MapToListAnimationController alloc] init];
    self.dismissTransitionController = [[DismissMapToListAnimationController alloc] init];
    
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
    [super viewDidAppear:NO];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    if(!self.mapView.userLocationVisible) if (!currentLocation) currentLocation = [appDelegate.locationManager getCurrentLocation];
    
    if (hasAppearedOnce == NO) {
        
        NSDictionary* filter = [appDelegate.databaseManager getUsersCurrentCriteria];
        
        NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
        
        double meters = (miles * 1609.34);
        
        CLLocationDistance radius = meters;

        [self centerMapOnLocation:currentLocation isUserLocation:NO AndRadius:radius animate:YES addCompletion:^(BOOL success){
            
            [self.view layoutIfNeeded];
            
            if (success) {
                                
                [self reloadDealsAddCompletion:^(BOOL reloadSuccess) {
                    if(reloadSuccess){
                        [self.mapView layoutIfNeeded];
                        hasAppearedOnce = YES;
                    }
                }];
                
            }
            
        }];
        
    }

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapView setDelegate:nil];
}

- (IBAction)menuBtnPressed:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.drawerController slideDrawerSide:MMDrawerSideRight Animated:YES];
    
    [appDelegate.drawerController setDelegate:self];
    
}

- (IBAction)filterBtnPressed:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    BudgetPickerViewController* budgetView = (BudgetPickerViewController*) [appDelegate.drawerController leftDrawerViewController];
    
    budgetView.delegate = self;

    [appDelegate.drawerController slideDrawerSide:MMDrawerSideLeft Animated:YES];
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
    
    [self centerMapOnLocation:currentLocation isUserLocation:YES AndRadius:USE_CURRENT_RADIUS animate:YES addCompletion:^(BOOL success) {
        
    }];
}

#pragma mark -
#pragma mark - Deal Methods
-(void)reloadDealsAddCompletion:(generalBlockResponse) completionHandler;
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    NSDictionary* criteria = [appDelegate.databaseManager getUsersCurrentCriteria];
    
    NSLog(@"%@", criteria);
    
    [appDelegate.databaseManager fetchDeals:criteria addCompletionBlock:^(BOOL success) {

        if(success){
            AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            
            NSArray* deals = [appDelegate.databaseManager currentDeals];
            
            NSLog(@"%@", deals);
            
            if(deals && deals.count > 1){
                
                [self plotDealsOnMap:deals Animated:YES addCompletion:^(BOOL success) {
                    [self.view layoutIfNeeded];
                    
                    completionHandler(YES);
                }];
                
            }
            else if (deals.count == 1)
            {
                Deal* deal = [deals objectAtIndex:0];
                [self plotDealOnMap:deal addCompletion:^(BOOL success) {
                    completionHandler(YES);
                }];
            }
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
        
        MKCoordinateRegion originalRegion = [self.mapView regionThatFits:MKCoordinateRegionMake(location.coordinate, self.mapView.region.span)];

        [UIView animateWithDuration:0.5 animations:^{
            
            [self.mapView setRegion:originalRegion];
            
        } completion:^(BOOL finished) {
            [self.mapView layoutIfNeeded];
            completionHandler(YES);
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

-(void)plotDealOnMap:(Deal *)deal addCompletion:(generalBlockResponse)completionHandler
{
    
    if(!deal) return;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSString* address = deal.address.copy;
    
    [appDelegate.databaseManager fetchGeocodeForAddress:address additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        
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
    
    __block NSMutableArray* annotations = [[NSMutableArray alloc] init];
    
    [appDelegate.databaseManager fetchGeocodeForAddresses:addressList additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
        
        NSArray* addressInfoList = (NSArray*) response;
        
        for (Deal* deal in deals) {
            
            NSString* deal_address = deal.addressString;
            
            for (int count = 0; count < addressInfoList.count; count++) {
                NSDictionary* addressInfo = addressInfoList[count];
                NSArray* value = [addressInfo valueForKey:@"formatted_address"];
                NSString* formattedAddress = [value objectAtIndex:0];
                
                if([deal_address caseInsensitiveCompare:formattedAddress] == NSOrderedSame){
                    
                    NSArray* coords = [addressInfo valueForKey:@"coordinates"];
                    NSString* latitude = [coords valueForKey:@"lat"];
                    NSString* longtitude = [coords valueForKey:@"lng"];
                    NSLog(@"lng %@ nd lat %@",longtitude, latitude);
                    NSLog(@"Deal %@", deal.addressString);
                    CLLocation* location = [appDelegate.locationManager managerCreateLocationFromStringLongtitude:longtitude andLatitude:latitude];
                    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                    
                    DealMapAnnotation* mapAnnotation = [[DealMapAnnotation alloc] initWithDeal:deal];
                    [mapAnnotation setCoordinate:coordinates];
                    
                    [annotations addObject:mapAnnotation];
                }
            }
        }
        
        [self.mapView addAnnotations:annotations.mutableCopy];
        completionHandler(YES);
        
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
-(void)dismissView
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        
        CLLocation* currentLocation = self.mapView.userLocation.location;
        
        NSDictionary* filter = [appDelegate.databaseManager getUsersCurrentCriteria];
        
        NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
        
        if (miles <= 5) miles = miles;
        else if(miles > 5 && miles <= 10) miles = 9;
        else miles = 15;
        
        double meters = (miles * 1609.34);
        
        CLLocationDistance radius = meters;
        
        [self centerMapOnLocation:currentLocation isUserLocation:NO AndRadius:radius animate:YES addCompletion:^(BOOL success) {
            
            [self.view layoutIfNeeded];
            
            [self reloadDealsAddCompletion:^(BOOL success) {
                
                if(success){
                    [self.view layoutIfNeeded];
                }
            }];
            
        }];
        
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
    CLLocation* annotationLocation = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
    
    [self centerMapOnLocation:annotationLocation isUserLocation:NO AndRadius:USE_CURRENT_RADIUS animate:YES addCompletion:^(BOOL success) {
        
        if(success){
            
            [self prepareAnnotationCalloutViewForAnnotationView:view addCompletionBlock:^(BOOL hasCompleted) {
                
                if (hasCompleted) {
                    [self.view layoutIfNeeded];
                }
                
            }];
        }
        
    }];


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
    
    DealMapAnnotation* a = (DealMapAnnotation*) view.annotation;
    
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
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        PSDealDetailViewController* detailedViewController = (PSDealDetailViewController*) [storyboard instantiateViewControllerWithIdentifier:@"PSDealsDetailViewController"];
        
        detailedViewController.venueName = a.dealAnnotated.venueName;
        
        detailedViewController.descriptionText = a.dealAnnotated.dealDescription;
        
        detailedViewController.addressText = [NSString stringWithFormat:@"\n%@ \n"
                              "%@, %@ %@", a.dealAnnotated.address, a.dealAnnotated.city, a.dealAnnotated.state, a.dealAnnotated.zipcode];
        
        detailedViewController.phoneText = [NSString stringWithFormat:@"\n%@", a.dealAnnotated.phoneNumber];
        
        detailedViewController.dealSelected = a.dealAnnotated;
        
        [self.annotationCalloutView addSubview:detailedViewController.view];
        
        [detailedViewController.view setFrame:self.annotationCalloutView.bounds];
        
        detailedViewController.view.layer.cornerRadius = 5.0f;
        
        completionBlock(YES);
        
    }];
    
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionController;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[PSAllDealsTableViewController class]]) {
        return self.dismissTransitionController;
    }
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
