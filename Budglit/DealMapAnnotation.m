//
//  DealMapAnnotation.m
//  Budglit
//
//  Created by Emmanuel Franco on 11/3/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealMapAnnotation.h"

@implementation DealMapAnnotation
@synthesize coordinate = _coordinate;

-(instancetype)initWithTitle:(NSString *)title Location:(NSString *)locationName Discipline:(NSString *)discipline
{
    self = [super init];
    
    if(!self) return nil;
    
    self.title = title;
    self.locationName = locationName;
    self.discipline = discipline;
    return self;
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
