//
//  AccountManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;
@class DatabaseEngine;
@class BudgetManager;
@class AccountEngine;
@class UserAccount;

typedef void (^generalReturnBlockResponse)(id object);
typedef void (^generalBlockResponse)(BOOL success);

@protocol AccountManagerDelegate <NSObject>
@optional
-(void) credentialsSaved;
-(void) credentialsNotSaved;
-(void) loginFailedWithError:(NSError*)error;
-(void) logoutSucessfully;
-(void) signupSucessfully;
-(void) signupFailedWithError:(NSError*)error;
-(void) emailSentSucessfully;
-(void) emailSentFailed;
@end

@interface AccountManager : NSObject

@property (nonatomic, strong) id <AccountManagerDelegate> delegate;
@property (nonatomic, strong) AccountEngine* engine;
@property (nonatomic, strong) UserAccount *signedAccount;

+(AccountManager*) sharedAccountManager;

-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)signup:(NSDictionary*)newCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalReturnBlockResponse)signUpCompletionHandler;

-(void)login:(NSDictionary*)loginCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalBlockResponse)completionHandler;

-(void)logoutFromDomain:(NSString*)domainName addCompletion:(generalReturnBlockResponse)completionHandler;

-(UserAccount*)getSignedAccount;

-(id)getValidationValue:(NSDictionary*)validationInfo;

-(void)removeUserAccountClearSavedAccount:(BOOL)clear AddCompletion:(generalBlockResponse)completionHandler;

-(void)validateSessionForDomain:(NSString*)domain addCompletion:(generalReturnBlockResponse) completionHandler;

-(void)removeAccountSessionCookieForDomain:(NSString*)domainName addCompletion:(generalBlockResponse)completionHandler;

-(void)passwordResetEmail:(NSDictionary*) emailCredentials;

-(BOOL)checkLoggedOut:(NSDictionary*)loggedOutInfo;

@end
