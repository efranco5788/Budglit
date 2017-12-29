//
//  MapViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Deal.h"
#import "DealMapAnnotation.h"
#import "DrawerViewController.h"
#import "LocationServiceManager.h"
#import "MMDrawerBarButtonItem.h"

@interface MapViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIButton *filterBtn;

- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)filterBtnPressed:(id)sender;

-(void)centerMapOnLocation:(CLLocation*)location AndRadius:(CLLocationDistance)radius;

-(void)fitAllAnnotations:(BOOL)shouldZoom;

-(void)clearMap;

-(void)clearMapRemoveUserLocation:(BOOL)remove;

-(void)plotDealOnMap:(Deal*)deal;

-(void)plotDealsOnMap:(NSArray*)deals;

-(void)plotDealsOnMap:(NSArray*)deals Animated:(BOOL)animate;

@end
