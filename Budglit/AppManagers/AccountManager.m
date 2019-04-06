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

#define HOST_NAME @"https://www.budglit.com"
#define VALID_KEY @"valid"
#define LOGGED_OUT_KEY @"loggedOut"

static AccountManager* sharedManager;

@interface AccountManager() <EngineDelegate>
{
    dispatch_queue_t backgroundQueue;
    
}

@end

@implementation AccountManager

static AccountManager* sharedManager;

+(id)sharedAccountManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[self alloc] initWithEngineHostName:HOST_NAME];
        
    });
    
    return sharedManager;
}

-(id)initWithEngineHostName:(NSString *)hostName
{
    self = [super initWithEngineHostName:hostName];
    
    if (!self) return nil;
    
    self.engine = [[AccountEngine alloc] initWithHostName:hostName];
    
    (self.engine).delegate = self;

    return self;
}

-(BOOL)checkLoggedOut:(NSDictionary *)loggedOutInfo
{
    if(!loggedOutInfo) return NO;
    
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
-(UserAccount*)managerSignedAccount
{
    UserAccount* user = [self.engine signedAccount];
    
    if(!user) return nil;
    else return user;
}

-(void)removeUserAccountClearSavedAccount:(BOOL)clear AddCompletion:(generalBlockResponse)completionHandler
{
    [self.engine deleteLoggedInUserAccountAddCompletion:^(BOOL success) {
        
        if(success){
            
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
                
                UserAccount* user = [self.engine parseUserAccount:userInfo];
                
                if(!user) completionHandler(NO);
                else{
                    
                    if(save){
                        
                        [self.engine saveLoggedInUserAccount:user addCompletion:^(BOOL success) {
                            
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
            signUpCompletionHandler(dataResponse);
        }
        else if ([dataResponse isKindOfClass:[UIAlertController class]])
        {
            signUpCompletionHandler(dataResponse);
            
        }
        else if([dataResponse isKindOfClass:[NSDictionary class]])
        {
            UserAccount* user = [self.engine parseUserAccount:dataResponse];
            
            NSLog(@"%@", user);
            
            if(!user){
                
                NSLog(@"There was an issue parsing the user account. ");
                signUpCompletionHandler(nil);

            }
            else{
                
                if(save){
                    
                    [self.engine saveLoggedInUserAccount:user addCompletion:^(BOOL success) {
                        if(success) signUpCompletionHandler(user);
                    }];
                    
                }
                else signUpCompletionHandler(user);
                
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
#pragma mark - Engine Delegates
-(void)requestFailedWithError:(NSDictionary *)info
{
    NSString* failedTitle = @"Connection Issue";
    NSString* failedMessage = @"Oops. It seems we are having some issues on our end. Please try again later";
    NSString* retry = @"OK";
    
    UIAlertAction* actionRetry = [UIAlertAction actionWithTitle:retry style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController* failedAlert = [UIAlertController alertControllerWithTitle:failedTitle message:failedMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [failedAlert addAction:actionRetry];
    
    [self.delegate networkRequestFailedWithError:failedAlert];
}

@end
