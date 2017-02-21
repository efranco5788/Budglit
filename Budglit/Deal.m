//
//  Deal.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Deal.h"
#import "MZTimerLabel/MZTimerLabel.h"

#define kDefaultDateFormat @"yyyy-MM-dd HH:mm:ss"

@interface Deal()
{
    CGRect tableCellPosition;
}

@end

@implementation Deal

@synthesize venueName, venueDescription, dealDescription, address, phoneNumber, city, state;

-(id)initWithVenueName:(NSString *)venue andVenueAddress:(NSString *)anAddress andVenueDescription:(NSString *)aVenueDes andVenueTwtrUsername:(NSString *)useranme andDate:(NSString *)dateString andStartDate:(NSString *)start andEndDate:(NSString *)end andDealDescription:(NSString *)aDealDescription andPhoneNumber:(NSString *)aNumber andCity:(NSString *)aCity andState:(NSString *)aState andZipcode:(NSString *)aZip andBudget:(double)aBudget andDealID:(NSInteger)aDealID andURLImage:(NSString *)url andAddTags:(NSArray *)dealTags
{
    self = [super init];
    
    if(self)
    {
        dealID = aDealID;
        self.venueName = venue;
        self.venueTwtrUsername = useranme;
        self.address = anAddress;
        self.venueDescription = aVenueDes;
        self.dealDescription = aDealDescription;
        self.startDate = start;
        self.endDate = end;
        self.phoneNumber = aNumber;
        self.city = aCity;
        self.state = aState;
        self.zipcode = aZip;
        budget = aBudget;
        self.tags = dealTags;
        self.imgStateObject = [[ImageStateObject alloc] init];
        
        if (![url isEqual:nil]) {
            self.imgStateObject.imagePath = url;
        }
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:NSLocalizedString(@"DATE_FORMAT", nil)];
        
        NSDate* date = [dateFormatter dateFromString:dateString];
        
        self.dealDate = date;
    }
    
    return self;
}

-(void)setOriginalPosition:(CGRect)frame
{
    tableCellPosition = frame;
}

-(CGRect)getOriginalPosition
{
    return tableCellPosition;
}

-(NSString *)getAddressString
{
    NSString* stringAddress = [[NSString alloc] initWithFormat:@"%@, %@, %@", self.address, self.city, self.state];
    
    return stringAddress;
}

-(void) setCoordinates:(CLLocationCoordinate2D) locationCoordinates
{
    coordinates = locationCoordinates;
}

-(CLLocationCoordinate2D) getCoordinates
{
    return coordinates;
}

-(NSString *)detailDescription
{
    NSString* detail = [[NSString alloc] init];
    
    return detail;
}

-(void)addTags:(NSArray *)tags
{
    NSMutableArray* tmpDeals = [self.tags mutableCopy];
    
    if ([tags isEqual:[NSNull null]]) {
        return;
    }
    
    for (NSString* tag in tags) {
        [tmpDeals addObject:tag];
    }
    
    self.tags = [tmpDeals copy];
    
}

-(UILabel*)generateCountDownEndDate:(UILabel*)aLabel
{
    if (!self.eventCountDwn){

        self.eventCountDwn = [[MZTimerLabel alloc] initWithLabel:aLabel andTimerType:MZTimerLabelTypeTimer];
        
        self.eventCountDwn.timeFormat = @"dd:HH:mm:ss ";
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:kDefaultDateFormat];
        
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        NSDate* evntEndDate = [formatter dateFromString:self.endDate];
        
        NSLog(@"%@", evntEndDate);
        
        [self.eventCountDwn setCountDownToDate:evntEndDate];
    }
    
    [self.eventCountDwn start];
    
    return aLabel;
}

-(void)dealloc
{
    
}

@end
