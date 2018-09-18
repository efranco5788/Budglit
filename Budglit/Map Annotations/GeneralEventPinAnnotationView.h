//
//  GeneralEventPinAnnotationView.h
//  Budglit
//
//  Created by Emmanuel Franco on 1/30/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GeneralEventPinAnnotationView.h"
#import "CustomCalloutViewController.h"

@interface GeneralEventPinAnnotationView : MKPinAnnotationView

@property (nonatomic, strong) CustomCalloutViewController* calloutView;
@property (nonatomic, assign) BOOL showCustomCallOut;

-(void)setCustomCallout:(BOOL)shouldShowCallout;
-(void) showCustomCallout;

@end
