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
    self = [self initWithPostalCode:nil andDistance:nil];
    
    if(!self) return nil;
    
    return self;
    
}

-(instancetype)initWithPostalCode:(NSString*)postalCode
{
    self = [self initWithPostalCode:postalCode andDistance:nil];
    
    if (!self) return nil;
    
    return self;
    
}

-(instancetype)initWithPostalCode:(NSString *)postalCode andDistance:(NSString *)distance
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.postalCode = postalCode;
    
    self.distanceFromLocation = distance;
    
    return self;
}

@end
