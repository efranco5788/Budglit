//
//  DealViewModel.m
//  Budglit
//
//  Created by Emmanuel Franco on 9/25/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "DealViewModel.h"
#import "Deal.h"
#import "DealMapAnnotation.h"

@implementation DealViewModel

-(instancetype)initWithDeal:(Deal *)aDeal
{
    self = [super init];
    
    if(!self) return nil;
    
    self.deal = aDeal;
    
    self.descriptionText = self.deal.dealDescription;
    
    self.distanceText = [NSString stringWithFormat:@"%.1f mi away", self.deal.annotation.getDistanceFromUser];
    
    self.venueName = self.deal.venueName;
    
    self.phoneText = [NSString stringWithFormat:@"\n%@", self.deal.phoneNumber];
    
    self.addressText = [NSString stringWithFormat:@"\n%@ \n"
                        "%@, %@ %@", self.deal.address, self.deal.city, self.deal.state, self.deal.zipcode];
    
    if(self.deal.budget <= 0) self.budgetText = [NSString stringWithFormat:@"Free"];
    else if(self.deal.budget > 0 && self.deal.budget < 1) self.budgetText = [NSString stringWithFormat:@"Under a dollar"];
    else{
        
        NSInteger budgetInteger = ceil(self.deal.budget);

        self.budgetText = [NSString stringWithFormat:@"Under $%li", (long)budgetInteger];
    }
    
    return self;
}

@end
