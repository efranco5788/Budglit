//
//  GNEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

@protocol GNEngineDelegate <NSObject>
@optional
-(void) zipcodeCoordinatesFound:(NSDictionary*)coordinates;
-(void) zipcodeCoordinatesFailedWithError:(NSError*)error;
-(void) nearbyPostalCodesFound:(NSDictionary*) postalCodes;
-(void) nearbyPostalCodesFailedWithError:(NSError*) error;
@end

@interface GNEngine : Engine

@property (nonatomic, strong) id <GNEngineDelegate> delegate;

-(instancetype) init;

-(instancetype) initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

-(void)GNFetchNeabyPostalCodesWithCoordinates:(NSDictionary *)parameters;

-(void)GNFetchNeabyPostalCodesWithPostalCode:(NSDictionary *)parameters;
@end
