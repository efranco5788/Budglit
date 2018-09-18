//
//  DealMapAnnotation.h
//  Budglit
//
//  Created by Emmanuel Franco on 11/3/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Deal.h"
#import "DealDetailViewController.h"
#import "GeneralEventPinAnnotationView.h"
#import "CustomCalloutViewController.h"

@interface DealMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) Deal* parentDeal;
@property (nonatomic, strong) CustomCalloutViewController* calloutView;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) NSString* locationName;
@property (nonatomic, strong) NSString* distanceFromUserString;
@property (nonatomic, strong) NSString* discipline;
@property (nonatomic, assign) BOOL showCustomCallOut;

+(MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation;

-(id)initForDeal:(Deal*)deal;

-(void)setFrameForCalloutView:(CGRect)tmpFrame;

-(void)setCustomCallout:(BOOL)shouldShowCallout;

-(CLLocationDistance)getDistanceFromUser;

-(NSString*)getDistanceFromUserString;

-(void)setDistanceFromUser:(double)distance;

-(void)showCustomCallout;

@end
