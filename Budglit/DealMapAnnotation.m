//
//  DealMapAnnotation.m
//  Budglit
//
//  Created by Emmanuel Franco on 11/3/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealMapAnnotation.h"
#import "GeneralEventAnnotationView.h"

@implementation DealMapAnnotation
@synthesize coordinate = _coordinate;

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *returnedAnnotationView = (GeneralEventAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DealMapAnnotation class])];
    
    if(returnedAnnotationView == nil)
    {
        returnedAnnotationView =  [[GeneralEventAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([DealMapAnnotation class])];
        
        //((MKPinAnnotationView *)returnedAnnotationView).pinTintColor = [MKPinAnnotationView purplePinColor];
        //((MKPinAnnotationView *)returnedAnnotationView).animatesDrop = YES;
        //((MKPinAnnotationView *)returnedAnnotationView).canShowCallout = YES;
    }
    
    return returnedAnnotationView;
}


-(id)initWithDeal:(Deal *)deal
{
    self = [super init];
    
    if(!self) return nil;
    
    if(deal){
        self.dealAnnotated = deal;
        self.title = deal.venueName;
        self.locationName = deal.venueName;
        self.discipline = @"Event";
    }
    
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

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

-(NSString *)subtitle
{
    return self.locationName;
}






@end
