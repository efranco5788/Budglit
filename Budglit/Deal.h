//
//  Deal.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DealMapAnnotation.h"
#import "ImageStateObject.h"

#define DEAL_ID_KEY @"dealID"

@class MZTimerLabel;

@protocol DealDelegate <NSObject>
@optional
-(void)eventEnded;
@end

@interface Deal : NSObject
{
    NSInteger dealID;
    double budget;
    
}

extern NSString* const kDefaultEventEndNotification;

@property (nonatomic, assign) id<DealDelegate> delegate;
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
@property (nonatomic, strong) DealMapAnnotation* mapAnnotation;
@property (nonatomic, strong) ImageStateObject* imgStateObject;
@property (nonatomic, strong) MZTimerLabel* eventCountDwn;

- (instancetype) initWithVenueName:(NSString*) venue andVenueAddress:(NSString*) anAddress andVenueDescription:(NSString*) aVenueDes andVenueTwtrUsername:(NSString*)useranme andDate:(NSString*)dateString andStartDate:(NSString*)start andEndDate:(NSString*)end andDealDescription:(NSString*) aDealDescription andPhoneNumber:(NSString*) aNumber andCity:(NSString*) aCity andState:(NSString*) aState andZipcode:(NSString*)aZip andBudget:(double) aBudget andDealID:(NSInteger) aDealID andURLImage:(NSString*) url andAddTags:(NSArray*) dealTags NS_DESIGNATED_INITIALIZER;


@property (NS_NONATOMIC_IOSONLY, getter=getAddressString, readonly, copy) NSString *addressString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *detailDescription;

-(NSInteger)getID;

-(void)setAnnotationWithTitle:(NSString*)title locationName:(NSString*)name andDiscipline:(NSString*)discipline;

-(DealMapAnnotation*)getMapAnnotation;

-(void)setCoordinates:(CLLocationCoordinate2D)coords;

-(CLLocationCoordinate2D)getCoordinates;

-(NSString*)getDealIDString;

-(void)addTags:(NSArray*)tags;

-(UILabel*)generateCountDownEndDate:(UILabel*)aLabel;

-(UILabel*)animateCountdownEndDate:(UILabel*)aLabel;


@property (NS_NONATOMIC_IOSONLY, getter=getOriginalPosition) CGRect originalPosition;
@end
