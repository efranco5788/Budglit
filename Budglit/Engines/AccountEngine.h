//
//  AccountEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"
#import "UserAccount.h"

@interface AccountEngine : Engine

//@property (nonatomic, strong) id <AccountEngineDelegate> delegate;

-(instancetype)init;

-(instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(NSDictionary *)constructDefaultUserAccount;

-(UserAccount*)parseUserAccount:(NSDictionary*)data;

-(UserAccount*)signedAccount;

-(void)saveLoggedInUserAccount:(UserAccount*)user addCompletion:(generalBlockResponse)completionHandler;

-(void)deleteLoggedInUserAccountAddCompletion:(generalBlockResponse)completionHandler;

-(void)loginWithCredentials:(NSDictionary*)userCredentials addCompletion:(blockResponse)completionHandler;

-(void)signupWithNewAccount:(NSDictionary*)userCredentials addCompletion:(blockResponse)completionHandler;

-(void)sendPasswordResetEmail:(NSDictionary*) email;

@end
