//
//  AccountEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"
#import "UserAccount.h"

typedef void (^fetchedResponse)(id dataResponse);

@protocol AccountEngineDelegate <NSObject>
@optional
-(void) credentialsSaved;
-(void) credentialsNotSaved;
-(void) loginSucessful:(NSDictionary*)userInfo;
-(void) loginFailedWithError:(NSError*)error;
-(void) logoutSucessfully;
-(void) signupSucessfully;
-(void) signupFailedWithError:(NSError*)error;
-(void) emailSentSucessfully;
-(void) emailSentFailed;
@end

@interface AccountEngine : Engine

@property (nonatomic, strong) id <AccountEngineDelegate> delegate;

-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)validateSessionAddCompletion:(generalBlockResponse)completionHandler;

-(void)fetchSessionUserAccountAddCompletionHandler:(fetchedResponse)completionHandler;

-(void)loginWithCredentials:(NSDictionary*) userCredentials;

-(void)signupWithNewAccount:(NSDictionary*) userCredentials;

-(void)sendPasswordResetEmail:(NSDictionary*) email;

@end
