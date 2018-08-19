//
//  AccountManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "AccountManager.h"
#import "AppDelegate.h"
#import "AccountEngine.h"
#import "BudgetManager.h"
#import "DatabaseEngine.h"
#import "UserAccount.h"
#import <dispatch/dispatch.h>

#define VALID_KEY @"valid"
#define LOGGED_OUT_KEY @"loggedOut"

static AccountManager* sharedManager;

@interface AccountManager() <AccountEngineDelegate>
{
    dispatch_queue_t backgroundQueue;
    
}

//@property (nonatomic, strong) UserAccount* signedAccount;

@end

@implementation AccountManager

+(AccountManager *)sharedAccountManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    
    return sharedManager;
}

-(instancetype)init
{
    self = [self initWithEngineHostName:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithEngineHostName:(NSString *)hostName
{
    self = [super init];
    
    if (!self) return nil;
    
    self.engine = [[AccountEngine alloc] initWithHostName:hostName];
    
    (self.engine).delegate = self;
    
    //self.signedAccount = [[UserAccount alloc] init];
    
    return self;
}

-(BOOL)checkLoggedOut:(NSDictionary *)loggedOutInfo
{
    if(!loggedOutInfo) return nil;
    
    BOOL value = [loggedOutInfo valueForKey:LOGGED_OUT_KEY];
    
    return value;
}

#pragma mark -
#pragma mark - Cookie Session Validator Methods
-(id)getValidationValue:(NSDictionary *)validationInfo
{
    if(!validationInfo) return nil;
    
    return [validationInfo valueForKey:VALID_KEY];
}

-(void)validateSessionForDomain:(NSString *)domain addCompletion:(generalReturnBlockResponse)completionHandler
{
    NSString* sessionDomain = [domain lowercaseString];
    
    if(!sessionDomain) sessionDomain = [[self.engine baseURLString] lowercaseString];
    
    NSHTTPCookie* cookie = [self.engine getSavedCookieForDomain:sessionDomain];
    
    NSLog(@"%@", cookie);
    
    if(cookie == nil)completionHandler(nil);
    else{
        
        __block NSNumber* validValue;
        
        [self.engine cookieHasExpired:cookie addCompletion:^(BOOL hasPassed) {
            
            if(hasPassed == NO){
                
                validValue = [NSNumber numberWithBool:YES];
                
                NSDictionary* results = [NSDictionary dictionaryWithObject:validValue forKey:VALID_KEY];
                
                completionHandler(results);
                
            }
            else{
                
                validValue = [NSNumber numberWithBool:NO];
                
                NSDictionary* results = [NSDictionary dictionaryWithObject:validValue forKey:VALID_KEY];
                
                completionHandler(results);
                
            } // end of else statement
            
        }];
        
    }
    
    
}

-(void)removeAccountSessionCookieForDomain:(NSString *)domainName addCompletion:(generalBlockResponse)completionHandler
{
    NSHTTPCookie* cookie = [self.engine getSavedCookieForDomain:domainName];
    
    if(!cookie) completionHandler(YES);
    else{
        
        [self.engine removeCookie:cookie addCompletion:^(BOOL success) {
            
            completionHandler(success);
            
        }];
        
    }
    
}


#pragma mark -
#pragma mark - Signed User Account Methods
// Get User information already stored in device
-(UserAccount*)getSignedAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* userData = [defaults valueForKey:NSLocalizedString(@"ACCOUNT", nil)];
    
    if (!userData) return nil;
    
    UserAccount* user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    return user;
}

-(void)removeUserAccountClearSavedAccount:(BOOL)clear AddCompletion:(generalBlockResponse)completionHandler
{
    [self.engine deleteLoggedInUserAccountAddCompletion:^(BOOL success) {
        
        if(success){
            
            if(clear){
                [self.signedAccount clear];
            }
            
            
        }
       
        completionHandler(success);
        
    }];
}

#pragma mark -
#pragma mark - Requests for user accounts
// Fetch User Account from server
-(void)login:(NSDictionary *)loginCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalBlockResponse)completionHandler
{
    [self.engine loginWithCredentials:loginCredentials addCompletion:^(id dataResponse) {
        
        if(dataResponse){
            
            if([dataResponse isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* userInfo = (NSDictionary*) dataResponse;
                
                NSLog(@"%@", userInfo);
                
                
                self.signedAccount = [self.engine parseUserAccount:userInfo];
                
                NSLog(@"%@", self.signedAccount);
                
                if(!self.signedAccount) completionHandler(NO);
                else{
                    
                    if(save){
                        
                        [self.engine saveLoggedInUserAccount:self.signedAccount addCompletion:^(BOOL success) {
                            if(success)completionHandler(YES);
                        }];
                    }
                    else completionHandler(YES);
                    
                }
                
            } // end of response kind of class finder
            
        }
        else completionHandler(NO);
        
    }]; // End of loginWithCredentials block
    
    
}

-(void)signup:(NSDictionary *)newCredentials shouldSaveCredentials:(BOOL)save addCompletion:(generalReturnBlockResponse)signUpCompletionHandler
{
    [self.engine signupWithNewAccount:newCredentials.copy addCompletion:^(id dataResponse) {
       
        if([dataResponse isKindOfClass:[NSError class]])
        {
            
        }
        else if ([dataResponse isKindOfClass:[UIAlertController class]])
        {
            signUpCompletionHandler(dataResponse);
            
        }
        else if([dataResponse isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"%@", dataResponse);
            
            self.signedAccount = [self.engine parseUserAccount:dataResponse];
            
            if(!self.signedAccount) signUpCompletionHandler(nil);
            else{
                
                if(save){
                    
                    [self.engine saveLoggedInUserAccount:self.signedAccount addCompletion:^(BOOL success) {
                        if(success)signUpCompletionHandler(dataResponse);
                    }];
                    
                }
                else signUpCompletionHandler(dataResponse);
                
            }
            
        }
        else signUpCompletionHandler(nil);
    }];
}

-(void)passwordResetEmail:(NSDictionary *)emailCredentials
{
    NSDictionary* email = emailCredentials.copy;
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        
        [self.engine sendPasswordResetEmail:email];
        
    });
}

-(void)logoutFromDomain:(NSString *)domainName addCompletion:(generalReturnBlockResponse)completionHandler
{
    NSString* domain;
    
    if(!domainName){
        
        NSError *error = NULL;
        
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(www)+.+[a-z]+.+com" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:self.engine.baseURLString options:0 range:NSMakeRange(0, [self.engine.baseURLString length])];

        
        if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
            domain = [self.engine.baseURLString substringWithRange:rangeOfFirstMatch];
        }
        else domain = self.engine.baseURLString;

    }
    else domain = domainName;
    
    NSLog(@"%@", domain);
    

    [self.engine logoutAddCompletion:^(BOOL loggedOutSuccess) {
        
        if (loggedOutSuccess == TRUE) {
            
            [self removeAccountSessionCookieForDomain:domain addCompletion:^(BOOL cookieRemoved) {
                
                if(cookieRemoved == TRUE){
                    
                    [self removeUserAccountClearSavedAccount:YES AddCompletion:^(BOOL removed) {
                        
                        if(removed == TRUE){
                            
                            NSDictionary* info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:LOGGED_OUT_KEY];
                            
                            completionHandler(info);
                            
                        }
                        
                    }];
                    
                }
                
            }];
            
        }
    }];
    
}

#pragma mark -
#pragma mark - Account Engine Delegates
-(void)loginFailedWithError:(NSError *)error
{
    [self.delegate loginFailedWithError:error];
}

-(void)signupSucessfully
{
    [self.delegate signupSucessfully];
}

-(void)signupFailedWithError:(NSError *)error
{
    [self.delegate signupFailedWithError:error];
}

@end
