//
//  DealParser.m
//  Budglit
//
//  Created by Emmanuel Franco on 8/1/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealParser.h"

#define KEY_DEAL_ID @"@dealID"
#define KEY_DEAL_BUDGET @"dealBudget"
#define KEY_VENUE_ZIPCODE @"zipcode"
#define KEY_DEAL_DESCRIPTION @"dealDescription"
#define KEY_DEAL_DATE @"date_of_event"
#define KEY_DEAL_START @"duration_start"
#define KEY_DEAL_END @"duration_end"
#define KEY_DEAL_END_OF_DAY @"duration_endOfDay"
#define KEY_DEAL_TAGS @"tags"
#define KEY_VENUE_PHONE_NUMBER @"phone"
#define KEY_VENUE_NAME @"name"
#define KEY_VENUE_ADDRESS @"address"
#define KEY_VENUE_CITY @"city"
#define KEY_VENUE_STATE @"state"
#define KEY_VENUE_IMAGE_URL @"imageURL"
#define KEY_VENUE_TWTR_USERNAME @"twtrUsername"

@implementation DealParser

-(instancetype)init
{
    self = [self initParser];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initParser
{
    self = [super init];
    
    if (!self) return nil;
    
    NSLog(@"Deal Parser created");
    
    return self;
}

-(void)parseDeals:(NSArray *)list addCompletionHandler:(parseCompletionBlock)completionBlock
{
    if (list.count >= 1) {
        
        NSMutableArray* dealList = [[NSMutableArray alloc] init];
        
        for (id dic in list) {
            
            NSDictionary* deal = dic[@"deal"];
            
            NSLog(@"%@", deal);
            
            NSInteger dealID = [deal[@"dealID"] integerValue];
            
            NSString* dealDate = deal[KEY_DEAL_DATE];
            
            NSString* startDate = deal[KEY_DEAL_START];
            
            NSString* endDate = deal[KEY_DEAL_END];
            
            //id dayObj = deal[KEY_DEAL_END_OF_DAY];
            
            //BOOL endOfDay = [dayObj boolValue];
            
            double dealBudget = [deal[KEY_DEAL_BUDGET] doubleValue];
            
            NSString* dealDescription = deal[KEY_DEAL_DESCRIPTION];
            
            NSString* dealTags = deal[KEY_DEAL_TAGS];
            
            NSString* venue = deal[KEY_VENUE_NAME];
            
            NSString* venueAddress = deal[KEY_VENUE_ADDRESS];
            
            NSString* venueCity = deal[KEY_VENUE_CITY];
            
            NSString* venueState = deal[KEY_VENUE_STATE];
            
            NSString* twtrUsername = deal[KEY_VENUE_TWTR_USERNAME];
            
            NSString* zipcode = [deal[KEY_VENUE_ZIPCODE] stringValue];
            
            NSString* venuePhone = deal[KEY_VENUE_PHONE_NUMBER];
            
            NSString* imgURL = deal[KEY_VENUE_IMAGE_URL];
            
            NSArray* arryOfTags;
            
            if ([dealTags isEqual:[NSNull null]]) {
                
                arryOfTags = NULL;
                
            }
            else arryOfTags = [dealTags componentsSeparatedByString:@","];
            
            Deal* newDeal = [[Deal alloc] initWithVenueName:venue andVenueAddress:venueAddress andVenueDescription:nil andVenueTwtrUsername:twtrUsername andDate:dealDate andStartDate:startDate andEndDate:endDate andDealDescription:dealDescription andPhoneNumber:venuePhone andCity:venueCity andState:venueState andZipcode:zipcode andBudget:dealBudget andDealID:dealID andURLImage:imgURL andAddTags:arryOfTags];
            
            [dealList addObject:newDeal];
        }
        
        NSArray* arryofDeals = dealList.copy;
        
        completionBlock(arryofDeals);
        
    }
}

@end
