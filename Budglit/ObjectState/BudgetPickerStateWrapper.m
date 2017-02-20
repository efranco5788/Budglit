//
//  BudgetPickerStateWrapper.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "BudgetPickerStateWrapper.h"
#import "State.h"
#import "ClearState.h"
#import "ReadyState.h"

@implementation BudgetPickerStateWrapper

+(void)goNextState:(id)sender
{
    
}

-(id)initWithCustomObject:(id)customObject
{    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    if (customObject) {
        self.contextObject = customObject;
    }
    else{
        return nil;
    }
    
    return self;
}

-(void)stateClear
{
    self.currentState = [[ClearState alloc] initState];
}

-(BOOL)isClear
{
    if ([self.currentState isMemberOfClass:[ClearState class]]) {
        return YES;
    }
    
    return NO;
}

@end
