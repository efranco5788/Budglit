//
//  AccountEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

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

-(id)init;

-(id)initWithHostName:(NSString*)hostName;

-(void) loginWithCredentials:(NSDictionary*) userCredentials;

-(void) signupWithNewAccount:(NSDictionary*) userCredentials;

-(void) sendPasswordResetEmail:(NSDictionary*) email;

@end
