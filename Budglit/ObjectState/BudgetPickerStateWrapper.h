//
//  BudgetPickerStateWrapper.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class State;
@class ClearState;
@class ReadyState;

@interface BudgetPickerStateWrapper : NSObject

@property (nonatomic, strong) id contextObject;

@property (nonatomic, strong) State* currentState;

+(void)goNextState:(id)sender;

-(instancetype) initWithCustomObject:(id)customObject NS_DESIGNATED_INITIALIZER;

-(void) stateClear;

@property (NS_NONATOMIC_IOSONLY, getter=isClear, readonly) BOOL clear;

@end
