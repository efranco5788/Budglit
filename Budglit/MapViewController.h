//
//  MapViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "MapViewModel.h"
#import "Deal.h"
#import "DealMapAnnotation.h"
#import "GeneralEventPinAnnotationView.h"
#import "DrawerViewController.h"
#import "LocationServiceManager.h"
#import "MMDrawerBarButtonItem.h"

@interface MapViewController : UIViewController

typedef void (^generalBlockResponse)(BOOL success);

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) MapViewModel* viewModel;
@property (strong, nonatomic) IBOutlet UIButton* menuBtn;
@property (strong, nonatomic) IBOutlet UIButton* filterBtn;
@property (strong, nonatomic) UIView* backgroundScreen;
@property (weak, nonatomic) IBOutlet UIButton *updateEventsBtn;
@property (weak, nonatomic) IBOutlet UILabel *lbl_NetworkConnectivityIssue;


-(IBAction)currentLocationBtnPressed:(UIButton *)sender;
-(IBAction)menuBtnPressed:(id)sender;
-(IBAction)filterBtnPressed:(id)sender;
-(IBAction)updateEventsBtnPressed:(id)sender;
-(IBAction)updateEventsBtnWasDragged:(id)sender withEvent:(UIEvent*)event;
-(IBAction)swipeView:(UISwipeGestureRecognizer*)sender;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeftEventBtn;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightEventBtn;

-(void)fitAllAnnotations:(BOOL)shouldZoom addCompletion:(generalBlockResponse)completionHandler;

-(void)clearMap;

-(void)clearMapRemoveUserLocation:(BOOL)remove;

-(void)scanNewRegion:(MKCoordinateRegion*)region addCompletion:(generalBlockResponse)completionHandler;

-(void)plotDealsOnMap:(NSArray*)deals Animated:(BOOL)animate addCompletion:(generalBlockResponse) completionHandler;

@end
