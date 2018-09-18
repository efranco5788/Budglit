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
    double distanceFromUser;
}
@synthesize coordinate = _coordinate;
@synthesize title = _title;


+(MKAnnotationView*)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* returnedAnnotationView = (GeneralEventPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DealMapAnnotation class])];
    
    if(returnedAnnotationView == nil)
    {
        returnedAnnotationView =  [[GeneralEventPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([DealMapAnnotation class])];
        
        NSLog(@"was nil %@", returnedAnnotationView);
        
        //((MKPinAnnotationView *)returnedAnnotationView).pinTintColor = [MKPinAnnotationView purplePinColor];
        //((MKPinAnnotationView *)returnedAnnotationView).animatesDrop = YES;
        //((MKPinAnnotationView *)returnedAnnotationView).canShowCallout = YES;
    }
    else returnedAnnotationView.annotation = annotation;
    
    return returnedAnnotationView;
}


-(id)initForDeal:(Deal *)deal
{
    self = [super init];
    
    if(!self) return nil;
    
    if(!deal) return nil;
    
    self.parentDeal = deal;
    
    _title = self.parentDeal.venueName;
    NSLog(@"--------------- Title Set -------------");
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
    return distanceFromUser;
}

-(NSString*)getDistanceFromUserString
{
    return self.distanceFromUserString;
}

-(void)setDistanceFromUser:(double)distance
{
    if (distance < 0) distance = 0;
    
    distanceFromUser = distance;
    
    self.distanceFromUserString = [NSString stringWithFormat:@"%.1f mi", distance];
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}



@end
