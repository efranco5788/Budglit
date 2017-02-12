//
//  BudgetManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "BudgetManager.h"

static BudgetManager* sharedManager;

@implementation BudgetManager

+(BudgetManager *)sharedBudgetManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

-(id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.budgetHistory = [[NSArray alloc] init];
    
    return self;
}

-(void)addBudget:(NSString*)aBudget
{
    NSString* budget;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([aBudget isEqualToString:NSLocalizedString(@"MINIMUM_AMOUNT_STRING_VALUE", nil)]) {
        budget = NSLocalizedString(@"FREE", nil);
    }
    else
    {
        budget = [NSString stringWithFormat:@"$%@", aBudget];
        
    }
    
    [defaults setObject:budget forKey:NSLocalizedString(@"BUDGET", nil)];
    
    [defaults synchronize];
    
    [self recordBudget:aBudget];
    
    NSLog(@"Budget has been added.");
    
    budget = nil;
    defaults = nil;
    
    [self.delegate budgetDidFinish];
    
}

-(BOOL)isBudgetExists
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userBudget = [userDefaults objectForKey:NSLocalizedString(@"BUDGET", nil)];
    
    if ([userBudget isEqualToString:NSLocalizedString(@"DEFAULT_BUDGET", nil)]) {
        
        return NO;
    }
    else{
        return YES;
    }
}

-(NSString *)retreieveBudget
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:NSLocalizedString(@"USA", nil)]];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* budgetString = [defaults objectForKey:NSLocalizedString(@"BUDGET", nil)];
    
    return budgetString;
}

-(void)resetBudget
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:NSLocalizedString(@"BUDGET", nil)];
    
    [defaults synchronize];
    
    NSLog(@"Budget has been cleared");
}

-(void) recordBudget:(NSString*)budget
{
    NSMutableArray* copyBudgetHistory = self.budgetHistory.mutableCopy;
    
    [copyBudgetHistory addObject:budget];
    
    self.budgetHistory = copyBudgetHistory.copy;
}

@end