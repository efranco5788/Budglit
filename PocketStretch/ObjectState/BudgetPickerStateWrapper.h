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

-(id) initWithCustomObject:(id)customObject;

-(void) stateClear;

-(BOOL) isClear;

@end
