//
//  AccountEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AccountEngine.h"

#define REGISTER_PATH @"register"
#define LOGIN_PATH @"login"
#define LOGOUT_PATH @"logout"
#define VALIDATE_SESSION_PATH @"validate"
#define RESET_PASSWORD @"reset_password"
#define KEY_AUTHENTICATED @"authenticated"
//#define KEY_ACCOUNTS_FOUND @"accounts"
#define KEY_ACCOUNTS_FOUND @"accountExists"
#define KEY_MESSAGE @"message"
//#define KEY_EMAIL_SENT @"email_sent"
#define KEY_CREATED @"created"
#define KEY_LOGGED_IN @"isLogin"
#define KEY_LOGGED_OUT @"loggedOut"
#define KEY_ACCOUNT_TYPE @"type"
#define KEY_USER_ID @"_id"
#define KEY_USER @"user"
#define KEY_EMAIL @"email"
#define KEY_FIRST_NAME @"firstName"
#define KEY_LAST_NAME @"lastName"
#define KEY_IMAGE_URL @"userImg"
#define KEY_ERROR @"error"
#define KEY_MESSAGE @"message"

@interface AccountEngine() <EngineDelegate>

@end

@implementation AccountEngine

-(instancetype) init
{
    self = [self initWithHostName:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype) initWithHostName:(NSString*)hostName
{
    self = [super initWithHostName:hostName];
    
    if (!self) return nil;
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self setDelegate:self];
    
    return self;
}

-(NSDictionary*)constructDefaultUserAccount
{
    UserAccount* loggedAccount = [[UserAccount alloc] initWithFirstName:NSLocalizedString(@"DEFAULT_NO_ACCOUNT_NAME", nil) andLastName:nil];
    
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:loggedAccount];
    
    NSArray* defaultObjects = @[accountData];
    
    NSArray* defaultKeys = @[ NSLocalizedString(@"ACCOUNT", nil)];
    
    NSDictionary* userAccountDefault = [NSDictionary dictionaryWithObjects:defaultObjects forKeys:defaultKeys];
    
    return userAccountDefault;
}

-(UserAccount*)parseUserAccount:(NSDictionary *)data
{
    if(!data) return nil;
    
    NSString* userID = [data valueForKey:KEY_USER_ID];
    NSString* usrType = [data valueForKey:KEY_ACCOUNT_TYPE];
    NSString* usrEmail = [data valueForKey:KEY_EMAIL];
    NSString* usrFName = [data valueForKey:KEY_FIRST_NAME];
    NSString* usrLName = [data valueForKey:KEY_LAST_NAME];
    NSString* usrImgURL = [data valueForKey:KEY_IMAGE_URL];
    
    NSLog(@"%@", data);
    
    UserAccount* account = [[UserAccount alloc] initWithFirstName:usrFName andLastName:usrLName andProfileImage:usrImgURL andEmail:usrEmail andID:userID];
    
    [account setAccountType:usrType];
    
    if(!account) return nil;
    
    return account;
}

-(UserAccount*)signedAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* userData = [defaults valueForKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    if (!userData) return nil;
    
    UserAccount* user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    return user;
}

-(void)saveLoggedInUserAccount:(UserAccount *)user addCompletion:(generalBlockResponse)completionHandler
{
    if(!user) completionHandler(false);
    else{
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:user];
        
        [userDefaults setValue:accountData forKey:NSLocalizedString(@"ACCOUNT", nil)];
        
        [userDefaults synchronize];
        
        completionHandler(true);
        
    }
    
}

-(void)deleteLoggedInUserAccountAddCompletion:(generalBlockResponse)completionHandler
{    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    [userDefaults synchronize];
    
    completionHandler(true);
}

-(void)loginWithCredentials:(NSDictionary *)userCredentials addCompletion:(blockResponse)completionHandler
{
    
    [self postRequestToPath:LOGIN_PATH parameters:userCredentials addCompletion:^(id responseObject) {
        
        if(!responseObject){
            
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again", nil)
                                       };
            
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:-57
                                             userInfo:userInfo];
            
            completionHandler(error);
            
        }
        else{
            
            NSInteger loggedIn = [[responseObject valueForKey:KEY_LOGGED_IN] integerValue];
            
            if (loggedIn == 0) completionHandler(nil);
            else{
                
                NSDictionary* dict = [responseObject valueForKey:KEY_USER];
                
                NSMutableDictionary* tmpUser = [[NSMutableDictionary alloc] init];
                
                NSLog(@"%@", dict);
                
                NSString* userID = [dict valueForKey:KEY_USER_ID] ?: @"";
                NSString* email = [dict valueForKey:KEY_EMAIL] ?: @"";
                NSString* fname = [dict valueForKey:KEY_FIRST_NAME] ?: @"";
                NSString* lname = [dict valueForKey:KEY_LAST_NAME] ?: @"";
                NSString* img = [dict valueForKey:KEY_IMAGE_URL] ?: @"";
                
                [tmpUser setValue:userID forKey:KEY_USER_ID];
                [tmpUser setValue:email forKey:KEY_EMAIL];
                [tmpUser setValue:fname forKey:KEY_FIRST_NAME];
                [tmpUser setValue:lname forKey:KEY_LAST_NAME];
                [tmpUser setValue:img forKey:KEY_IMAGE_URL];
                
                completionHandler(tmpUser.copy);
                
            } // End of else if logged in statement
            
            /*
            NSHTTPURLResponse* response = (NSHTTPURLResponse*) task.response;
            
            if(response.statusCode == 300){
                
            }
             */
            
        }
        
        
    }];
    
}

-(void)signupWithNewAccount:(NSDictionary *)userCredentials addCompletion:(blockResponse)completionHandler
{
    
    [self postRequestToPath:REGISTER_PATH parameters:userCredentials addCompletion:^(id responseObject) {
        
        NSDictionary* response = (NSDictionary*) responseObject;
        
        NSUInteger accountExistIntValue = [[response valueForKey:KEY_ACCOUNTS_FOUND] integerValue];
        
        NSString* message = [response valueForKey:KEY_MESSAGE];
        
        if (accountExistIntValue == 1) {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Account Exists" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            completionHandler(alert);
            
        }
        else{
            
            BOOL created = [[response valueForKey:KEY_CREATED] integerValue];
            
            if(created == YES){
                
                id userDict = [response valueForKey:KEY_USER];
                
                NSLog(@"%@", userDict);
                
                if (!userDict) completionHandler(nil);
                else{
                    
                    NSDictionary* user = (NSDictionary*) userDict;
                    
                    completionHandler(user);
                    
                }
                
            }
            else{
                
                NSDictionary* userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"User Account was not created", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again", nil)
                                           };
                
                NSError* err = [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:userInfo];
                
                completionHandler(err);
                
            }
        }
        
    }];
    
}

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler
{
    
    [self postRequestToPath:LOGOUT_PATH parameters:nil addCompletion:^(id responseObject) {
        
        if(!responseObject){
            completionHandler(false);
        }
        else{
            
            NSDictionary* response = (NSDictionary*) responseObject;
            NSInteger loggedOut = [[response valueForKey:KEY_LOGGED_OUT] integerValue];
            
            if(loggedOut == true){
                completionHandler(true);
            }
            else{
                completionHandler(false);
            }
        }
        
    }];
    

}

-(void)sendPasswordResetEmail:(NSDictionary *)email
{
    //    NSDictionary* emailCredentials = email;
    //
    //    MKNetworkOperation* resetPasswordOperation = [self operationWithPath:RESET_PASSWORD params:emailCredentials];
    //
    //    [resetPasswordOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
    //
    //        NSDictionary* response = [completedOperation responseJSON];
    //
    //        BOOL emailSent = [[response valueForKey:KEY_EMAIL_SENT] boolValue];
    //
    //        completionBlock(emailSent);
    //
    //    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
    //        errorBlock(error);
    //    }];
    //
    //    [self enqueueOperation:resetPasswordOperation];
}

-(void)updatesReceived:(NSNotification*)notification
{
    
}


@end
