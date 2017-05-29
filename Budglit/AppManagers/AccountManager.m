//
//  AccountManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AccountManager.h"
#import "AppDelegate.h"
#import "AccountEngine.h"
#import "BudgetManager.h"
#import "DatabaseEngine.h"
#import "UserAccount.h"
#import <dispatch/dispatch.h>

#define KEY_EMAIL @"email"
#define KEY_FIRST_NAME @"fName"
#define KEY_LAST_NAME @"lName"
#define KEY_IMAGE_URL @"profileIMG"

static AccountManager* sharedManager;

@interface AccountManager() <AccountEngineDelegate>
{
    dispatch_queue_t backgroundQueue;
    
}

@property (nonatomic, strong) UserAccount* signedAccount;

@end

@implementation AccountManager

+(AccountManager *)sharedAccountManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    
    return sharedManager;
}

-(id)initWithEngineHostName:(NSString *)hostName
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[AccountEngine alloc] initWithHostName:hostName];
    
    [self.engine setDelegate:self];
    
    //self.signedAccount = [[UserAccount alloc] init];
    
    return self;
}

-(UserAccount*)getSignedAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* userData = [defaults valueForKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    UserAccount* user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    return user;
}

-(void)login:(NSDictionary *)loginCredentials
{
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSDictionary* credentials = loginCredentials.copy;
    
    dispatch_async(backgroundQueue, ^{
        
        [self.engine loginWithCredentials:credentials];
        
    });
    
}

-(void)signup:(NSDictionary *)newCredentials
{
    NSDictionary* credentials = newCredentials.copy;
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        
        [self.engine signupWithNewAccount:credentials];
        
    });
}

-(void)saveCredentials
{
    if (!self.signedAccount) {
        [self.delegate credentialsNotSaved];
        return;
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:self.signedAccount];
    
    [userDefaults setValue:accountData forKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil];
    
    [self.delegate credentialsSaved];
}

-(void)passwordResetEmail:(NSDictionary *)emailCredentials
{
    NSDictionary* email = emailCredentials.copy;
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        
        [self.engine sendPasswordResetEmail:email];
        
    });
}

-(void)logout
{
    [self.signedAccount clear];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:self.signedAccount];
    
    [userDefaults setValue:accountData forKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil];
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    // Reset the budget amount
    [appDelegate.budgetManager resetBudget];
    
    [self.delegate logoutSucessfully];
}

#pragma mark -
#pragma mark - Account Engine Delegates
-(void)loginSucessful:(NSDictionary *)userInfo
{    
    NSString* usrEmail = [userInfo valueForKey:KEY_EMAIL];
    NSString* usrFName = [userInfo valueForKey:KEY_FIRST_NAME];
    NSString* usrLName = [userInfo valueForKey:KEY_LAST_NAME];
    NSString* usrImgURL = [userInfo valueForKey:KEY_IMAGE_URL];
    
    self.signedAccount = [[UserAccount alloc] initWithFirstName:usrFName andLastName:usrLName andProfileImage:usrImgURL andEmail:usrEmail andSessionID:nil];

    
    [self.delegate loginSucessful];
}

-(void)loginFailedWithError:(NSError *)error
{
    [self.delegate loginFailedWithError:error];
}

-(void)signupSucessfully
{
    [self.delegate signupSucessfully];
}

-(void)signupFailedWithError:(NSError *)error
{
    [self.delegate signupFailedWithError:error];
}

@end
