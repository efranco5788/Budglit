//
//  AccountEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AccountEngine.h"

#define LOGIN_PATH @"login_authentication.php"
#define SIGNUP_PATH @"signup.php"
#define RESET_PASSWORD @"reset_password.php"


#define KEY_PASSWORD @"user_password"
#define KEY_AUTHENTICATED @"authenticated"
#define KEY_EMAIL_SENT @"email_sent"
#define KEY_USER_INFO @"userInfo"
#define KEY_ERROR @"error"
#define ACCOUNT @"userAccount"

@implementation AccountEngine

-(id) init
{
    return [self initWithHostName:nil];
}

-(id) initWithHostName:(NSString*)hostName
{
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void) loginWithCredentials:(NSDictionary *)userCredentials
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:LOGIN_PATH parameters:userCredentials progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSDictionary* response = (NSDictionary*) responseObject;
        
        NSDictionary* user = [response valueForKey:KEY_USER_INFO];
        
        NSString* loginValue = [response valueForKey:KEY_AUTHENTICATED];
        
        NSUInteger loginIntValue = [loginValue integerValue];
        
        NSLog(@"%@", response);
        
        if (loginIntValue == 1) {
            [self.delegate loginSucessful:user];
        }
        else
        {
            [self.delegate loginFailedWithError:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
        [self.delegate loginFailedWithError:error];
        
    }];
    
}

-(void)signupWithNewAccount:(NSDictionary *)userCredentials
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:SIGNUP_PATH parameters:userCredentials progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        NSDictionary* response = (NSDictionary*) responseObject;
        
        NSString* accountCreatedValue = [response valueForKey:KEY_AUTHENTICATED];
        
        NSUInteger accountCreatedIntValue = [accountCreatedValue integerValue];
        
        if (accountCreatedIntValue == 1) {
            [self.delegate signupSucessfully];
        }
        else
        {
            [self.delegate signupFailedWithError:nil];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        [self.delegate signupFailedWithError:error];
        
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



@end
