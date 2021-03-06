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

#define DEAL_ID_KEY @"dealID"

@class MZTimerLabel;
@class DealMapAnnotation;

@protocol DealDelegate <NSObject>
@optional
-(void)eventEnded;
@end

@interface Deal : NSObject
{
    double budget;
}

extern NSString* const kDefaultEventEndNotification;

@property (nonatomic, assign) id<DealDelegate> delegate;
@property (nonatomic, strong) NSString* dealID;
@property (nonatomic, strong) NSString* venueName;
@property (nonatomic, strong) NSString* venueDescription;
@property (nonatomic, strong) NSString* venueTwtrUsername;
@property (nonatomic, strong) NSDate* dealDate;
@property (nonatomic, strong) NSString* endDate;
@property (nonatomic, strong) NSString* dealDescription;
@property (nonatomic, strong) NSArray* tags;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* standardizeAddress;
@property (nonatomic, strong) NSDictionary* addressInfo;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* zipcode;
@property (nonatomic, strong) ImageStateObject* imgStateObject;
@property (nonatomic, strong) MZTimerLabel* eventCountDwn;
@property (nonatomic, strong) DealMapAnnotation* annotation;

- (instancetype) initWithVenueName:(NSString*) venue andVenueAddress:(NSString*) anAddress andVenueDescription:(NSString*) aVenueDes andVenueTwtrUsername:(NSString*)useranme andDate:(NSString*)dateString andEndDate:(NSString*)end andDealDescription:(NSString*) aDealDescription andPhoneNumber:(NSString*) aNumber andCity:(NSString*) aCity andState:(NSString*) aState andZipcode:(NSString*)aZip andBudget:(double) aBudget andDealID:(NSString*) aDealID andURLImage:(NSString*) url andAddTags:(NSArray*) dealTags NS_DESIGNATED_INITIALIZER;


@property (NS_NONATOMIC_IOSONLY, getter=getAddressString, readonly, copy) NSString *addressString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *detailDescription;

@property (NS_NONATOMIC_IOSONLY, getter=getOriginalPosition) CGRect originalPosition;

-(double)budget;

-(void)addTags:(NSArray*)tags;

-(DealMapAnnotation*)createMapAnnotation;

-(void)displayMapAnnotation;

-(void)hideMapAnnotation;

-(CLLocationDistance)getDistanceFromUser;

-(UILabel*)generateCountDownEndDate:(UILabel*)aLabel;

-(UILabel*)animateCountdownEndDate:(UILabel*)aLabel;

@end
