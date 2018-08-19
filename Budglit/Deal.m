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
#define kDefaultTimeFormat @"dd:HH:mm:ss "
#define kEventEnded @"Event Ended"

@interface Deal() <MZTimerLabelDelegate>
{
    CGRect tableCellPosition;
    CLLocationCoordinate2D coordinates;
}

@end

@implementation Deal

NSString* const kDefaultEventEndNotification = @"EventEndNotification";

@synthesize venueName, venueDescription, dealDescription, address, phoneNumber, city, state;

-(instancetype)init
{
    self = [self initWithVenueName:nil andVenueAddress:nil andVenueDescription:nil andVenueTwtrUsername:nil andDate:nil andEndDate:nil andDealDescription:nil andPhoneNumber:nil andCity:nil andState:nil andZipcode:nil andBudget:0 andDealID:0 andURLImage:nil andAddTags:nil];

    if (!self) return nil;
    
    return self;
    
}

-(instancetype)initWithVenueName:(NSString *)venue andVenueAddress:(NSString *)anAddress andVenueDescription:(NSString *)aVenueDes andVenueTwtrUsername:(NSString *)useranme andDate:(NSString *)dateString andEndDate:(NSString *)end andDealDescription:(NSString *)aDealDescription andPhoneNumber:(NSString *)aNumber andCity:(NSString *)aCity andState:(NSString *)aState andZipcode:(NSString *)aZip andBudget:(double)aBudget andDealID:(NSString*)aDealID andURLImage:(NSString *)url andAddTags:(NSArray *)dealTags
{
    self = [super init];
    
    if(!self) return nil;
    
    if(self)
    {
        self.dealID = aDealID;
        self.venueName = venue;
        self.venueTwtrUsername = useranme;
        self.address = anAddress;
        self.venueDescription = aVenueDes;
        self.dealDescription = aDealDescription;
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

-(double)budget
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.maximumFractionDigits = 2;
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    
    NSString* formattedStringBudget = [formatter stringFromNumber:[NSNumber numberWithDouble:budget]];
    
    double roundedBudget = [formattedStringBudget doubleValue];

    return roundedBudget;
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
        
        self.eventCountDwn.timeFormat = kDefaultTimeFormat;
        
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
