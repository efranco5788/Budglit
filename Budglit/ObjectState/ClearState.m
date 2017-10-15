//
//  ClearState.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/2/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "ClearState.h"
#import "BudgetPickerStateWrapper.h"

@implementation ClearState

-(instancetype)initState
{
    self = [super initState];
    
    if (![self isMemberOfClass:[ClearState class]]) {
        return nil;
    }
    
    return self;
}

-(void)disableInterface:(id)sender
{
    if ([sender isMemberOfClass:[BudgetPickerStateWrapper class]]) {
        sender = (BudgetPickerStateWrapper*) sender;
        
        
    }
}

@end
