//
//  CityDataObject.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/15/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "CityDataObject.h"

@implementation CityDataObject

-(instancetype)init
{
    return [self initWithCity:nil State:nil stateAbbr:nil andPostal:nil];
}

-(instancetype)initWithCity:(NSString *)city State:(NSString *)state stateAbbr:(NSString *)abbr andPostal:(NSString *)postalCode
{
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.name = city;
    self.state = state;
    self.stAbbr = abbr;
    self.postal = postalCode;
    
    return self;
}

@end
