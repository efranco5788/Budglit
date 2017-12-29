//
//  DealMapAnnotation.h
//  Budglit
//
//  Created by Emmanuel Franco on 11/3/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DealMapAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* locationName;
@property (strong, nonatomic) NSString* discipline;

-(instancetype)initWithTitle:(NSString*)title Location:(NSString*)locationName Discipline:(NSString*)discipline;

@end
