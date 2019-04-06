//
//  AccountManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Manager.h"

@class AppDelegate;
@class DatabaseEngine;
@class BudgetManager;
@class AccountEngine;
@class UserAccount;


@protocol AccountManagerDelegate <NSObject>
@optional
-(void) networkRequestFailedWithError:(UIAlertController*)alertView;
@end

@interface AccountManager : Manager

@property (nonatomic, strong) id <AccountManagerDelegate> delegate;
@property (nonatomic, strong) AccountEngine* engine;


+(id)sharedAccountManager;

-(UserAccount*) managerSignedAccount;

-(void)signup:(NSDictionary*)newCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalReturnBlockResponse)signUpCompletionHandler;

-(void)login:(NSDictionary*)loginCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalCompletionHandler)completionHandler;

-(void)logoutFromDomain:(NSString*)domainName addCompletion:(generalReturnBlockResponse)completionHandler;

-(id)getValidationValue:(NSDictionary*)validationInfo;

-(void)removeUserAccountClearSavedAccount:(BOOL)clear AddCompletion:(generalCompletionHandler)completionHandler;

-(void)validateSessionForDomain:(NSString*)domain addCompletion:(generalReturnBlockResponse) completionHandler;

-(void)removeAccountSessionCookieForDomain:(NSString*)domainName addCompletion:(generalCompletionHandler)completionHandler;

-(void)passwordResetEmail:(NSDictionary*) emailCredentials;

-(BOOL)checkLoggedOut:(NSDictionary*)loggedOutInfo;

@end
