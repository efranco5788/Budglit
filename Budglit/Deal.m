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
#define kEventEnded @"Event Ended"

@interface Deal() <MZTimerLabelDelegate>
{
    CGRect tableCellPosition;
}

@end

@implementation Deal

NSString* const kDefaultEventEndNotification = @"EventEndNotification";

@synthesize venueName, venueDescription, dealDescription, address, phoneNumber, city, state;

-(instancetype)init
{
    self = [self initWithVenueName:nil andVenueAddress:nil andVenueDescription:nil andVenueTwtrUsername:nil andDate:nil andStartDate:nil andEndDate:nil andDealDescription:nil andPhoneNumber:nil andCity:nil andState:nil andZipcode:nil andBudget:0 andDealID:0 andURLImage:nil andAddTags:nil];
    
    if (!self) return nil;
    
    return nil;
        
        
}

-(instancetype)initWithVenueName:(NSString *)venue andVenueAddress:(NSString *)anAddress andVenueDescription:(NSString *)aVenueDes andVenueTwtrUsername:(NSString *)useranme andDate:(NSString *)dateString andStartDate:(NSString *)start andEndDate:(NSString *)end andDealDescription:(NSString *)aDealDescription andPhoneNumber:(NSString *)aNumber andCity:(NSString *)aCity andState:(NSString *)aState andZipcode:(NSString *)aZip andBudget:(double)aBudget andDealID:(NSInteger)aDealID andURLImage:(NSString *)url andAddTags:(NSArray *)dealTags
{
    self = [super init];
    
    if (!self) return nil;
    
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
        
        NSLog(@"%@", date);
        
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

#pragma mark - 
#pragma mark - Timer Label Methods
-(UILabel*)generateCountDownEndDate:(UILabel*)aLabel
{
    if (!self.eventCountDwn){

        self.eventCountDwn = [[MZTimerLabel alloc] initWithLabel:aLabel andTimerType:MZTimerLabelTypeTimer];
        
        (self.eventCountDwn).delegate = self;
        
        self.eventCountDwn.timeFormat = @"dd:HH:mm:ss ";
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:kDefaultDateFormat];
        
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        NSDate* evntEndDate = [formatter dateFromString:self.endDate];
        
        [self.eventCountDwn setCountDownToDate:evntEndDate];
    }
    
    [self.eventCountDwn start];
    
    return aLabel;
}

-(UILabel*)animateCountdownEndDate:(UILabel *)aLabel
{
    [aLabel setText:kEventEnded];
    
    return aLabel;
}

#pragma mark -
#pragma mark - Timer Delegate Methods
-(void)timerLabel:(MZTimerLabel *)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center postNotificationName:kDefaultEventEndNotification object:self];
}

#pragma mark -
#pragma mark - Memory Warning Methods
-(void)dealloc
{
    
}

@end
