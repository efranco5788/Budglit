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
#define KEY_ACCOUNTS_FOUND @"accounts"
#define KEY_MESSAGE @"message"
//#define KEY_EMAIL_SENT @"email_sent"
#define KEY_LOGGED_IN @"isLogin"
#define KEY_LOGGED_OUT @"loggedOut"
#define KEY_USER @"user"
#define KEY_USER_ID @"id"
//#define KEY_USER_INFO @"userInfo"
#define KEY_EMAIL @"email"
#define KEY_FIRST_NAME @"firstName"
#define KEY_LAST_NAME @"lastName"
#define KEY_IMAGE_URL @"userImg"
#define KEY_CREATED @"created"
#define KEY_ERROR @"error"

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

-(UserAccount *)parseUserAccount:(NSDictionary *)data
{
    if(!data) return nil;
    
    NSString* userID = [data valueForKey:KEY_USER_ID];
    NSString* usrEmail = [data valueForKey:KEY_EMAIL];
    NSString* usrFName = [data valueForKey:KEY_FIRST_NAME];
    NSString* usrLName = [data valueForKey:KEY_LAST_NAME];
    NSString* usrImgURL = [data valueForKey:KEY_IMAGE_URL];
    
    NSLog(@"%@", usrImgURL);
    
    UserAccount* account = [[UserAccount alloc] initWithFirstName:usrFName andLastName:usrLName andProfileImage:usrImgURL andEmail:usrEmail andID:userID];
    
    if(!account) return nil;
    
    return account;
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

-(void)loginWithCredentials:(NSDictionary *)userCredentials addCompletion:(fetchedResponse)completionHandler
{
//    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:LOGIN_PATH parameters:userCredentials progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if(!responseObject){
            
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again", nil)
                                       };
            
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:-57
                                             userInfo:userInfo];
            
            [self.delegate signupFailedWithError:error];
            
        }
        else{
            
            NSHTTPURLResponse* response = (NSHTTPURLResponse*) task.response;
            
            NSLog(@"Headers %@", response.allHeaderFields);
            
            NSLog(@"Response %@", responseObject);

            if(response.statusCode == 300){
                
            }
            else if (response.statusCode == 200){
                
                NSInteger loggedIn = [[responseObject valueForKey:KEY_LOGGED_IN] integerValue];
                
                if (loggedIn == 0) [self.delegate loginFailedWithError:nil];
                else{
                    
                    NSLog(@"%@", response.allHeaderFields);
                    
                    NSDictionary* dict = [responseObject valueForKey:KEY_USER];
                    
                    NSMutableDictionary* tmpUser = [[NSMutableDictionary alloc] init];
                    
                    NSLog(@"%@", dict);
                    
                    NSString* userID = [dict valueForKey:@"_id"];
                    NSString* email = [dict valueForKey:KEY_EMAIL];
                    NSString* fname = [dict valueForKey:KEY_FIRST_NAME];
                    NSString* lname = [dict valueForKey:KEY_LAST_NAME];
                    NSString* img = [dict valueForKey:KEY_IMAGE_URL];
                    
                    [tmpUser setValue:userID forKey:@"id"];
                    [tmpUser setValue:email forKey:KEY_EMAIL];
                    [tmpUser setValue:fname forKey:KEY_FIRST_NAME];
                    [tmpUser setValue:lname forKey:KEY_LAST_NAME];
                    [tmpUser setValue:img forKey:KEY_IMAGE_URL];

                    completionHandler(tmpUser.copy);
                    
                } // End of else if logged in statement
                
            } // End of else status code 200 statement
            
        } // End of if responseObject is defined
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) task.response;
        
        NSLog(@"%ld", (long)httpResponse.statusCode);
        
        NSDictionary* errInfo = error.userInfo;
        
        NSLog(@"Error %@", errInfo);
        
        [self.delegate loginFailedWithError:error];
        
    }];
    
}

-(void)signupWithNewAccount:(NSDictionary *)userCredentials addCompletion:(fetchedResponse)completionHandler
{
//    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:REGISTER_PATH parameters:userCredentials progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSDictionary* response = (NSDictionary*) responseObject;

        NSUInteger accountExistIntValue = [[response valueForKey:KEY_ACCOUNTS_FOUND] integerValue];
        
        NSString* message = [response valueForKey:KEY_MESSAGE];
        
        if (accountExistIntValue) {
            
            //[self.delegate signupSucessfully];
            if (accountExistIntValue <= 0) {
                completionHandler(nil);
            }
            else{
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Account Exists" message:message preferredStyle:UIAlertControllerStyleAlert];
                
                completionHandler(alert);
            }
            
        }
        else{
            
            BOOL created = [[response valueForKey:KEY_CREATED] integerValue];
            
            if(created){
                
                id userDict = [response valueForKey:KEY_USER];
                
                if (!userDict) completionHandler(nil);
                
                NSDictionary* user = (NSDictionary*) userDict;
                
                completionHandler(user);
                
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
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        //[self.delegate signupFailedWithError:error];
        completionHandler(error);
        
    }];
    
}

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler
{

    [self.sessionManager POST:LOGOUT_PATH parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
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
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        [self.delegate signupFailedWithError:error];
        //completionHandler(error);
        
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
