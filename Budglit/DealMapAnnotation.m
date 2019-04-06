//
//  DealMapAnnotation.m
//  Budglit
//
//  Created by Emmanuel Franco on 11/3/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealMapAnnotation.h"
#import "GeneralEventPinAnnotationView.h"
#import "AppDelegate.h"

#define kDEFAULT_DISTANCE_FROM_USER @"0"
#define kReuse_Identifier @"annotation"

@implementation DealMapAnnotation
{
    
}
@synthesize coordinate = _coordinate;
@synthesize title = _title;


+(MKAnnotationView*)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = (GeneralEventPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DealMapAnnotation class])];
    
    if(annotationView == nil)
    {
        annotationView =  [[GeneralEventPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([DealMapAnnotation class])];
        
        //NSLog(@"was nil %@", returnedAnnotationView);
        
        //((MKPinAnnotationView *)returnedAnnotationView).pinTintColor = [MKPinAnnotationView purplePinColor];
        //((MKPinAnnotationView *)returnedAnnotationView).animatesDrop = YES;
        //((MKPinAnnotationView *)returnedAnnotationView).canShowCallout = YES;
    }
    else annotationView.annotation = annotation;
    
    return annotationView;
}


-(id)initForDeal:(Deal *)deal
{
    self = [super init];
    
    if(!self) return nil;
    
    if(!deal) return nil;
    
    self.parentDeal = deal;
    
    _title = self.parentDeal.venueName;
    self.locationName = self.parentDeal.venueName;
    self.distanceFromUserString = [NSString stringWithFormat:@"%@ mi", kDEFAULT_DISTANCE_FROM_USER];
    self.discipline = @"Event";
    
    self.calloutView = [[CustomCalloutViewController alloc] init];
    
    [self.calloutView.view setBackgroundColor:[UIColor blueColor]];
    
    return self;
}

-(void)setFrameForCalloutView:(CGRect)tmpFrame
{
    [self.calloutView.view setFrame:tmpFrame];
}

-(void)showCustomCallout
{
    self.calloutView.view.alpha = 1.0f;
}

-(void)setCustomCallout:(BOOL)shouldShowCallout
{
    self.showCustomCallOut = shouldShowCallout;
}

-(CLLocationDistance)getDistanceFromUser
{
    LocationSeviceManager* locationManager = [LocationSeviceManager sharedLocationServiceManager];
    
    CLLocation* user = [locationManager getCurrentLocation];
    
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    
    CLLocationDistance distanceFromUserMeters = [locationManager managerDistanceMetersFromLocation:user toLocation:currentLocation];
    
    CLLocationDistance convertedDistance = [locationManager managerConvertDistance:distanceFromUserMeters];
    
    return convertedDistance;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}



@end
