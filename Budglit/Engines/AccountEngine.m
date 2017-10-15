//
//  AccountEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/1/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AccountEngine.h"

//#define LOGIN_PATH @"login_authentication.php"
//#define SIGNUP_PATH @"signup.php"
//#define RESET_PASSWORD @"reset_password.php"
//#define LOGIN_PATH @"authentication"
#define LOGIN_PATH @"login"
#define VALIDATE_SESSION_PATH @"validate"
#define LOGOUT_PATH @"logout"
#define SIGNUP_PATH @"signup"
#define RESET_PASSWORD @"reset_password"
#define KEY_PASSWORD @"user_password"
#define KEY_AUTHENTICATED @"authenticated"
#define KEY_EMAIL_SENT @"email_sent"
#define KEY_USER_INFO @"userInfo"
#define KEY_EMAIL @"email"
#define KEY_FIRST_NAME @"fName"
#define KEY_LAST_NAME @"lName"
#define KEY_IMAGE_URL @"profileIMG"
#define KEY_ERROR @"error"
#define ACCOUNT @"userAccount"
#define KEY_SESSION_ID @"connect.sid"

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
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)validateSessionAddCompletion:(generalBlockResponse)completionHandler
{
    self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    __block AccountEngine* selfEngine = self;
    [self.sessionManager GET:VALIDATE_SESSION_PATH parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[task response]);
        NSDictionary *headers = [response allHeaderFields];
        
        NSString* sessionID = [selfEngine extractSessionIDFromHeaders:headers];
        
        NSLog(@"Session Extracted is %@", sessionID);
        //NSLog(@"Current Session is %@", [selfEngine getSessionID]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error %@", error);
        [self logFailedRequest:task];
    }];
}

-(void)fetchSessionUserAccountAddCompletionHandler:(fetchedResponse)completionHandler
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSDictionary* params = [NSDictionary dictionaryWithObject:[self getSessionID] forKey:KEY_SESSION_ID];
    
    [self.sessionManager POST:LOGIN_PATH parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"response is %@", responseObject);
        completionHandler(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logFailedRequest:task];
        NSLog(@"Error %@", error);
        [self.delegate loginFailedWithError:error];
    }];
}

-(void) loginWithCredentials:(NSDictionary *)userCredentials
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    __block AccountEngine* selfEngine = self;
    [self.sessionManager POST:LOGIN_PATH parameters:userCredentials progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];

        //NSLog(@"%@", responseObject);
        NSInteger count = [[responseObject valueForKey:@"count"] integerValue];
        
        if (count < 1) [self.delegate loginFailedWithError:nil];
        else{
            
            NSDictionary* dict = (NSDictionary*) responseObject;
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) task.response;
            NSDictionary* headers = httpResponse.allHeaderFields;
            
            NSString* sessionID = [self extractSessionIDFromHeaders:headers];
            
            [self setSessionID:sessionID addCompletetion:^(BOOL success) {
                
                if (success) {
                    
                    NSMutableDictionary* tmpUser = [[NSMutableDictionary alloc] init];
                    
                    NSString* email = [dict valueForKey:KEY_EMAIL];
                    NSString* fname = [dict valueForKey:KEY_FIRST_NAME];
                    NSString* lname = [dict valueForKey:KEY_LAST_NAME];
                    NSString* img = [dict valueForKey:KEY_IMAGE_URL];
                    
                    [tmpUser setValue:email forKey:KEY_EMAIL];
                    [tmpUser setValue:fname forKey:KEY_FIRST_NAME];
                    [tmpUser setValue:lname forKey:KEY_LAST_NAME];
                    [tmpUser setValue:img forKey:KEY_IMAGE_URL];
                    
                    [selfEngine.delegate loginSucessful:tmpUser.copy];
                }
            }];
            
            //NSDictionary* user = [secondLayer valueForKey:KEY_USER_INFO];
            //NSString* loginValue = [secondLayer valueForKey:KEY_AUTHENTICATED];
            
//            NSString* email = [secondLayer valueForKey:KEY_EMAIL];
//            NSString* fname = [secondLayer valueForKey:KEY_FIRST_NAME];
//            NSString* lname = [secondLayer valueForKey:KEY_LAST_NAME];
//            NSString* img = [secondLayer valueForKey:KEY_IMAGE_URL];
            
//            [tmpUser setValue:email forKey:KEY_EMAIL];
//            [tmpUser setValue:fname forKey:KEY_FIRST_NAME];
//            [tmpUser setValue:lname forKey:KEY_LAST_NAME];
//            [tmpUser setValue:img forKey:KEY_IMAGE_URL];
            
            //[self.delegate loginSucessful:tmpUser.copy];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
        NSLog(@"Error %@", error);
        
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
        
        NSUInteger accountCreatedIntValue = accountCreatedValue.integerValue;
        
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

-(NSString *)extractSessionIDFromHeaders:(NSDictionary *)headers
{
    if(!headers) return nil;
    
    //[super extractSessionIDFromHeaders:headers];
    
    NSString* cookieInfo = [headers objectForKey:@"Set-Cookie"];
    
    NSMutableCharacterSet* delimiters = [[NSMutableCharacterSet alloc] init];
    [delimiters addCharactersInString:@"="];
    [delimiters addCharactersInString:@";"];
    
    NSArray* lines = [cookieInfo componentsSeparatedByCharactersInSet:delimiters.copy];
    
    NSString* sessionID = nil;
    for (int index = 0; index < lines.count; index++) {
        NSString* value = [lines objectAtIndex:index];
        
        if ([value isEqualToString:KEY_SESSION_ID]){
            NSInteger i = ++index;
            sessionID = [lines objectAtIndex:i];
            return sessionID;
        }
    }
    
    //returns nil if nothing is found
    return nil;
}

-(void)clearSession
{
    [super clearSession];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:KEY_SESSION_ID];
}

-(void)logout
{
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:LOGOUT_PATH parameters:nil progress:nil success:nil failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)logoutAddCompletion:(generalBlockResponse)completionHandler
{
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self.sessionManager POST:LOGOUT_PATH parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)updatesReceived:(NSNotification*)notification
{
    
}

@end
