//
//  MapViewModel.h
//  Budglit
//
//  Created by Emmanuel Franco on 2/23/19.
//  Copyright © 2019 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralEventPinAnnotationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapViewModel : NSObject

-(CLLocationDistance)getRadius;

-(void)setUpdateEventsBtn:(UIButton*)btn;

-(void)setAnnotationCalloutView:(UIView*)annotationView;

@end

NS_ASSUME_NONNULL_END
