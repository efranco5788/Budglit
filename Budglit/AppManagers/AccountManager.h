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

+(AccountManager*) sharedAccountManager;

-(id) initWithEngineHostName:(NSString*)hostName;

-(UserAccount*) getSignedAccount;

-(void) login:(NSDictionary*) loginCredentials;

-(void) logout;

-(void) signup:(NSDictionary*) newCredentials;

-(void) saveCredentials;

-(void) passwordResetEmail:(NSDictionary*) emailCredentials;

@end
