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

@protocol AccountManagerDelegate <NSObject>
@optional
-(void) credentialsSaved;
-(void) credentialsNotSaved;
-(void) loginSucessful;
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
//@property (nonatomic, getter=getSignedAccount, readonly, strong) UserAccount *signedAccount;
//@property (nonatomic, getter=getSignedAccount, strong) UserAccount *signedAccount;
@property (nonatomic, strong) UserAccount *signedAccount;

+(AccountManager*) sharedAccountManager;

-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void) login:(NSDictionary*) loginCredentials;

-(void) getSessionAccount:(NSString*)sessionID AddCompletion:(generalReturnBlockResponse)completionHandler;

-(UserAccount*) getSignedAccount;

-(void)sessionValidator;

-(void) clearSessionInfo;

-(void) logout;

-(void) logoutAddCompletion:(generalReturnBlockResponse)completionHandler;

-(void) signup:(NSDictionary*) newCredentials;

-(void) saveCredentials;

-(void) passwordResetEmail:(NSDictionary*) emailCredentials;

-(NSString*) getSessionID;

@end
