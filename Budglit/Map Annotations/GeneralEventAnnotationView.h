//
//  GeneralEventAnnotationView.h
//  Budglit
//
//  Created by Emmanuel Franco on 1/30/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GeneralEventAnnotationView.h"
#import "CustomCalloutViewController.h"

@interface GeneralEventAnnotationView : MKPinAnnotationView

@property (nonatomic, strong) CustomCalloutViewController* calloutView;
@property (nonatomic, assign) BOOL showCustomCallOut;

//-(instancetype)initWithTitle:(NSString*)title Location:(NSString*)locationName Discipline:(NSString*)discipline annotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setCustomCallout:(BOOL)shouldShowCallout;
-(void) showCustomCallout;

@end
