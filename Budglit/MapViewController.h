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
#import "GeneralEventAnnotationView.h"
#import "DrawerViewController.h"
#import "LocationServiceManager.h"
#import "MMDrawerBarButtonItem.h"

@interface MapViewController : UIViewController<UIGestureRecognizerDelegate>

typedef void (^generalBlockResponse)(BOOL success);

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIButton* menuBtn;
@property (strong, nonatomic) IBOutlet UIButton* filterBtn;
@property (strong, nonatomic) UIView* backgroundScreen;

- (IBAction)currentLocationBtnPressed:(UIButton *)sender;
- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)filterBtnPressed:(id)sender;

-(void)fitAllAnnotations:(BOOL)shouldZoom addCompletion:(generalBlockResponse)completionHandler;

-(void)clearMap;

-(void)clearMapRemoveUserLocation:(BOOL)remove;

-(void)scanNewRegion:(MKCoordinateRegion*)region addCompletion:(generalBlockResponse)completionHandler;

-(void)plotDealOnMap:(Deal*)deal addCompletion:(generalBlockResponse)completionHandler;

-(void)plotDealsOnMap:(NSArray*)deals;

-(void)plotDealsOnMap:(NSArray*)deals Animated:(BOOL)animate addCompletion:(generalBlockResponse) completionHandler;

@end
