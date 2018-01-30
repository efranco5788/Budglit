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

@interface MapViewController()<DrawerControllerDelegate, DatabaseManagerDelegate, BudgetPickerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, MKMapViewDelegate>
{
    BOOL hasAppearedOnce;
}

@property (strong, nonatomic) MapToListAnimationController* transitionController;
@property (strong, nonatomic) DismissMapToListAnimationController* dismissTransitionController;

@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.transitionController = [[MapToListAnimationController alloc] init];
    self.dismissTransitionController = [[DismissMapToListAnimationController alloc] init];
    
    hasAppearedOnce = FALSE;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UIImage* menuImg = [UIImage imageNamed:@"hamburger_menu.png"];
    
    [self.menuBtn setImage:menuImg forState:UIControlStateNormal];
    
    [super.view setNeedsLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    CLLocation* currentLocation = self.mapView.userLocation.location;
    
    if(!self.mapView.userLocationVisible) if (!currentLocation) currentLocation = [appDelegate.locationManager getCurrentLocation];
    
    if (!hasAppearedOnce) {
        
        NSDictionary* filter = [appDelegate.databaseManager getUsersCurrentCriteria];
        
        NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
        
        if (miles <= 5) miles = 5;
        else if(miles > 5 && miles <= 10) miles = 9;
        else miles = 15;
        
        double meters = (miles * 1609.34);
        
        CLLocationDistance radius = meters;

        
        [self centerMapOnLocation:currentLocation AndRadius:radius animate:NO addCompletion:^(BOOL success) {
            
            [self.view layoutIfNeeded];
            
            
            [self reloadDealsAddCompletion:^(BOOL success) {
                
                if(success){
                    
                    [self fitAllAnnotations:YES addCompletion:^(BOOL success) {
                        hasAppearedOnce = YES;
                    }];
                    
                }
            }];
            
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

#pragma mark -
#pragma mark - Deal Methods
-(void)reloadDealsAddCompletion:(generalBlockResponse) completionHandler;
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.databaseManager).delegate = self;
    
    NSDictionary* criteria = [appDelegate.databaseManager getUsersCurrentCriteria];
    
    [appDelegate.databaseManager fetchDeals:criteria addCompletionBlock:^(BOOL success) {
        
        if(success){
            AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            
            NSArray* deals = [appDelegate.databaseManager currentDeals];
            
            if(deals && deals.count > 1){
                
                if (self.mapView.annotations.count > 1) {
                    
                    NSArray* extractredAnnotations = [appDelegate.databaseManager.engine extractAnnotationsFromDeals:deals.mutableCopy];
                    
                    if(extractredAnnotations && ![extractredAnnotations isEqualToArray:self.mapView.annotations])
                    {
                        [self clearMapRemoveUserLocation:NO];
                    }
                    
                }
                
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

-(void)centerMapOnLocation:(CLLocation *)location AndRadius:(CLLocationDistance)radius animate:(BOOL)animated addCompletion:(generalBlockResponse)completionHandler
{
    if(!location) return;
    
    MKCoordinateRegion coordinateRegion =  MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    
    [self.mapView setRegion:coordinateRegion animated:animated];
    
    [self.mapView layoutIfNeeded];
    
    completionHandler(YES);
}

-(void)plotDealOnMap:(Deal *)deal addCompletion:(generalBlockResponse)completionHandler
{
    if(!deal) return;
    
    __block DealMapAnnotation* annotation = [deal getMapAnnotation];
    
    if(annotation) {
        
         [self.mapView addAnnotation:annotation];
    }
    else{
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        NSString* address = deal.address.copy;
        
        [appDelegate.databaseManager fetchGeocodeForAddress:address additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
            
            [appDelegate.databaseManager.engine addAnnotationToDeal:deal];
            [self.mapView addAnnotation:[deal getMapAnnotation]];
            //[self.mapView setNeedsDisplay];
            [super.view layoutIfNeeded];
            
            completionHandler(YES);
        }]; // End of geocoding method
        
    }
    
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
    
    NSMutableArray* mutableDeals = deals.count > 1 ? deals.mutableCopy : [appDelegate.databaseManager currentDeals];
    
    __block NSArray* unannotatedDeals = [appDelegate.databaseManager.engine extractUnannotatedDeals:mutableDeals].copy;
    
    if (unannotatedDeals.count < 1) {
        
        NSArray* annotations = [appDelegate.databaseManager.engine extractAnnotationsFromDeals:mutableDeals.copy];
        
        [appDelegate.databaseManager.engine groupAnnotationByCoordinates:annotations.mutableCopy addCompletionHandler:^(id response) {
            
            NSMutableDictionary* groupedAnnotations = (NSMutableDictionary*) response;
            
            [appDelegate.databaseManager.engine attemptToRepositionAnnotations:groupedAnnotations addCompletionHandler:^(BOOL success) {
                [self.mapView addAnnotations:annotations];
                //[self.mapView setNeedsDisplay];
                [super.view layoutIfNeeded];
                
                completionHandler(YES);
            }];
            
            
        }];
    }
    else{
        
        NSArray* addressList = [appDelegate.databaseManager.engine extractAddressFromDeals:unannotatedDeals];
        
        [appDelegate.databaseManager fetchGeocodeForAddresses:addressList additionalParams:nil shouldParse:YES addCompletetion:^(id response) {
            
            NSArray* addressInfoList = (NSArray*) response;
            
            for (Deal* deal in unannotatedDeals) {
                
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
                        [deal setAnnotationWithTitle:deal.venueName locationName:@"Fun Event" andDiscipline:@"Event"];
                        [deal setCoordinates:coordinates];
                    }
                }
            }

            NSMutableArray* currentDeals = [appDelegate.databaseManager currentDeals];
            NSMutableArray* annotations = [[NSMutableArray alloc] init];
            
            for (Deal* d in currentDeals) {
                DealMapAnnotation* annotation = d.getMapAnnotation;
                [annotations addObject:annotation];
            }

            
            [appDelegate.databaseManager.engine groupAnnotationByCoordinates:annotations addCompletionHandler:^(id response) {
                
                NSMutableDictionary* groupedAnnotations = (NSMutableDictionary*) response;
                
                [appDelegate.databaseManager.engine attemptToRepositionAnnotations:groupedAnnotations addCompletionHandler:^(BOOL success) {
                    [self.mapView addAnnotations:annotations];
                    //[self fitAllAnnotations:animate];
                    [self.mapView setNeedsDisplay];
                    
                    completionHandler(YES);
                }];
                
                
            }];
            
            
        }]; // End of database geocode fetching
    }
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PSAllDealsTableViewController* destinationController = (PSAllDealsTableViewController*) segue.destinationViewController;
    
    destinationController.transitioningDelegate = self;
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
        
        [self centerMapOnLocation:currentLocation AndRadius:radius animate:YES addCompletion:^(BOOL success) {
            
            [self.view layoutIfNeeded];
            
            
            [self reloadDealsAddCompletion:^(BOOL success) {
                
                if(success){
                    
                    [self fitAllAnnotations:YES addCompletion:^(BOOL success) {
                        
                        
                    }];
                    
                }
            }];
            
        }];
        
    }];
}

#pragma mark -
#pragma mark - Map View Delegate Methods
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"---------------------------------------------------------");
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}

#pragma mark -
#pragma mark - Navigation Methods
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

/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



#pragma mark
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
