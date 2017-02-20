//
//  PostalCode.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/13/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PostalCode.h"

@implementation PostalCode

-(instancetype)init
{
    return [self initWithPostalCode:nil andCoordinates:nil];
}

-(instancetype)initWithPostalCode:(NSString*)postalCode
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return [self initWithPostalCode:postalCode andCoordinates:nil];
    
}

-(instancetype)initWithPostalCode:(NSString*)postalCode andCoordinates:(NSDictionary*)coordinates
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    [self setPostalCode:postalCode];
    
    [self setCoordinates:coordinates];
    
    return self;
}

@end
