//
//  CityDataObject.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/15/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityDataObject : NSObject

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* state;

@property (nonatomic, strong) NSString* stAbbr;

@property (nonatomic, strong) NSString* postal;

-initWithCity:(NSString*)city State:(NSString*)state stateAbbr:(NSString*)abbr andPostal:(NSString*)postalCode;

@end
