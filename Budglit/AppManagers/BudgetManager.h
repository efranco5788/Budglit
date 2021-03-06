//
//  BudgetManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Manager.h"

@protocol BudgetManagerDelegate <NSObject>
@optional
-(void) budgetDidFinish;
@end

@interface BudgetManager : Manager

@property (nonatomic, assign) id<BudgetManagerDelegate> delegate;

@property (nonatomic, copy) NSArray* budgetHistory;

@property (NS_NONATOMIC_IOSONLY, getter=isBudgetExists, readonly) BOOL budgetExists;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *retreieveBudget;

+(id) sharedBudgetManager;

-(instancetype) init;

-(void) addBudget:(NSString*)aBudget;

-(void) resetBudget;

@end

