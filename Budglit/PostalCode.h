//
//  PostalCode.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/13/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostalCode : NSObject

@property (nonatomic, strong) NSString* postalCode;

@property (nonatomic, strong) NSString* distanceFromLocation;

-(instancetype) init;

-(instancetype) initWithPostalCode:(NSString*)postalCode;

-(instancetype) initWithPostalCode:(NSString *)postalCode andDistance:(NSString*)distance NS_DESIGNATED_INITIALIZER;

@end
