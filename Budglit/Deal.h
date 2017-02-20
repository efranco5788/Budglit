//
//  Deal.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ImageStateObject.h"

@class MZTimerLabel;

@interface Deal : NSObject
{
    NSInteger dealID;
    double budget;
    CLLocationCoordinate2D coordinates;
}

@property (nonatomic, strong) NSString* venueName;
@property (nonatomic, strong) NSString* venueDescription;
@property (nonatomic, strong) NSString* venueTwtrUsername;
@property (nonatomic, strong) NSDate* dealDate;
@property (nonatomic, strong) NSString* startDate;
@property (nonatomic, strong) NSString* endDate;
@property (nonatomic, strong) NSString* dealDescription;
@property (nonatomic, strong) NSArray* tags;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* zipcode;
@property (nonatomic, strong) ImageStateObject* imgStateObject;
@property (nonatomic, strong) MZTimerLabel* eventCountDwn;

- (id) initWithVenueName:(NSString*) venue andVenueAddress:(NSString*) anAddress andVenueDescription:(NSString*) aVenueDes andVenueTwtrUsername:(NSString*)useranme andDate:(NSString*)dateString andStartDate:(NSString*)start andEndDate:(NSString*)end andDealDescription:(NSString*) aDealDescription andPhoneNumber:(NSString*) aNumber andCity:(NSString*) aCity andState:(NSString*) aState andZipcode:(NSString*)aZip andBudget:(double) aBudget andDealID:(NSInteger) aDealID andURLImage:(NSString*) url andAddTags:(NSArray*) dealTags;

-(void) setCoordinates:(CLLocationCoordinate2D) locationCoordinates;

-(NSString*)getAddressString;

-(CLLocationCoordinate2D) getCoordinates;

-(NSString*)detailDescription;

-(void)addTags:(NSArray*)tags;

-(UILabel*)generateCountDownEndDate:(UILabel*)aLabel;

-(void)setOriginalPosition:(CGRect)frame;

-(CGRect)getOriginalPosition;
@end
