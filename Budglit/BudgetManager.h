//
//  BudgetManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BudgetManagerDelegate <NSObject>
@optional
-(void) budgetDidFinish;
@end

@interface BudgetManager : NSObject

+(BudgetManager*) sharedBudgetManager;

@property (nonatomic, assign) id<BudgetManagerDelegate> delegate;

@property (nonatomic, copy) NSArray* budgetHistory;

-(id) init;

-(BOOL) isBudgetExists;

-(NSString*) retreieveBudget;

-(void) addBudget:(NSString*)aBudget;

-(void) resetBudget;

@end

