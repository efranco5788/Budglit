//
//  DealParser.m
//  Budglit
//
//  Created by Emmanuel Franco on 8/1/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealParser.h"
#import "AppDelegate.h"

#define KEY_DEAL_ID @"_id"
#define KEY_DEAL_BUDGET @"budget"
#define KEY_VENUE_ZIPCODE @"zipcode"
#define KEY_DEAL_DESCRIPTION @"dealDescription"
//#define KEY_DEAL_DATE @"date_of_event"
#define KEY_DEAL_DATE @"date"
#define KEY_DEAL_START @"duration_start"
#define KEY_DEAL_END @"duration_end"
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

-(NSArray*)parseDeals:(NSArray *)list
{
    //NSLog(@"%@", list);
    
    if(!list){return nil;}
    
    if (list.count >= 1) {
        
        NSMutableArray* dealList = [[NSMutableArray alloc] init];
        
        for (id eventDic in list) {
            
            NSArray* eventArray = eventDic[@"deal"];
            
            NSDictionary* event = [eventArray firstObject];
            
            NSString* dealID = event[KEY_DEAL_ID];
            
            NSString* dealDate = event[KEY_DEAL_DATE];
            
            NSString* endDate = event[KEY_DEAL_END];
            
            double dealBudget = [event[KEY_DEAL_BUDGET] doubleValue];
            
            NSString* dealDescription = event[KEY_DEAL_DESCRIPTION];
            
            NSString* dealTags = event[KEY_DEAL_TAGS];
            
            NSString* venue = event[KEY_VENUE_NAME];
            
            NSString* venueAddress = event[KEY_VENUE_ADDRESS];
            
            NSString* venueCity = event[KEY_VENUE_CITY];
            
            NSString* venueState = event[KEY_VENUE_STATE];
            
            NSString* twtrUsername = event[KEY_VENUE_TWTR_USERNAME];
            
            NSString* zipcode = [event[KEY_VENUE_ZIPCODE] stringValue];
            
            NSString* venuePhone = event[KEY_VENUE_PHONE_NUMBER];
            
            NSString* imgURL = event[KEY_VENUE_IMAGE_URL];
            
            NSArray* arryOfTags;
            
            if ([dealTags isEqual:[NSNull null]]) {
                
                arryOfTags = NULL;
                
            }
            else arryOfTags = [dealTags componentsSeparatedByString:@","];
            
            AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            
            NSString* localEventTime = [appDelegate.databaseManager.engine convertUTCDateToLocalString:dealDate];
            
            NSLog(@"%@", localEventTime);
            
            Deal* newDeal = [[Deal alloc] initWithVenueName:venue andVenueAddress:venueAddress andVenueDescription:nil andVenueTwtrUsername:twtrUsername andDate:dealDate andEndDate:endDate andDealDescription:dealDescription andPhoneNumber:venuePhone andCity:venueCity andState:venueState andZipcode:zipcode andBudget:dealBudget andDealID:dealID andURLImage:imgURL andAddTags:arryOfTags];
            
            [dealList addObject:newDeal];
        }
        
        return dealList.copy;
        
    }
    else return nil;
    
}

@end
