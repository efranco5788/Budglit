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
#import "PSDealDetailViewController.h"
#import "GeneralEventAnnotationView.h"
#import "CustomCalloutViewController.h"

@interface DealMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) CustomCalloutViewController* calloutView;
@property (strong, nonatomic) Deal* dealAnnotated;
@property (copy, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* locationName;
@property (strong, nonatomic) NSString* discipline;
@property (nonatomic, assign) BOOL showCustomCallOut;

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation;

-(id)initWithDeal:(Deal*)deal;
-(void)setFrameForCalloutView:(CGRect)tmpFrame;
-(void)setCustomCallout:(BOOL)shouldShowCallout;
-(void) showCustomCallout;

@end
