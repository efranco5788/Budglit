//
//  UserAccount.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/15/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "UserAccount.h"

#define kHOST_ACCOUNT @"host"
#define kATTENDEE_ACCOUNT @"attendee"

static UserAccount* loggedAccount;

typedef NS_ENUM(NSUInteger, AccountType) {
    Account_Default = 0,
    Account_Host = 1,
    Account_Attendee = 2,
};

@interface UserAccount(){
    AccountType accountType;
}

@property (nonatomic, strong) NSString* userID;

@end


@implementation UserAccount

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithFirstName:nil andLastName:nil andProfileImage:nil andEmail:nil andID:nil];
    
    if (!self) {
        return nil;
    }

    self.userID = [aDecoder decodeObjectForKey:@"id"];
    self.firstName = [aDecoder decodeObjectForKey:NSLocalizedString(@"DEFAULT_KEY_FIRST_NAME", nil)];
    self.lastName = [aDecoder decodeObjectForKey:NSLocalizedString(@"DEFAULT_KEY_LAST_NAME", nil)];
    self.email = [aDecoder decodeObjectForKey:NSLocalizedString(@"DEFAULT_KEY_EMAIL", nil)];
    self.imageURL = [aDecoder decodeObjectForKey:NSLocalizedString(@"DEFAULT_KEY_IMAGE_URL", nil)];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID forKey:@"id"];
    [aCoder encodeObject:self.firstName forKey:NSLocalizedString(@"DEFAULT_KEY_FIRST_NAME", nil)];
    [aCoder encodeObject:self.lastName forKey:NSLocalizedString(@"DEFAULT_KEY_LAST_NAME", nil)];
    [aCoder encodeObject:self.email forKey:NSLocalizedString(@"DEFAULT_KEY_EMAIL", nil)];
    [aCoder encodeObject:self.imageURL forKey:NSLocalizedString(@"DEFAULT_KEY_IMAGE_URL", nil)];
}

-(instancetype)init
{
    self = [self initWithFirstName:@"No name" andLastName:nil andProfileImage:nil andEmail:nil andID:nil];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName
{
    self = [self initWithFirstName:fName andLastName:lName andProfileImage:nil andEmail:nil andID:nil];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL
{
    self = [self initWithFirstName:fName andLastName:lName andProfileImage:URL andEmail:nil andID:nil];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(instancetype)initWithFirstName:(NSString *)fName andLastName:(NSString *)lName andProfileImage:(NSString*)URL andEmail:(NSString *)anEmail
{
    
    self = [self initWithFirstName:fName andLastName:lName andProfileImage:URL andEmail:anEmail andID:nil];
    
    if (!self) return nil;
    
    return self;
}

-(instancetype)initWithFirstName:(NSString *)fName andLastName:(NSString *)lName andProfileImage:(NSString*)URL andEmail:(NSString *)anEmail andID:(NSString *)userID
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.userID = userID;
    
    if (!fName || [fName isEqual:[NSNull null]]) self.firstName = NSLocalizedString(@"DEFAULT_NAME", nil);
    else self.firstName = fName;
    
    
    if (!lName || [lName isEqual:[NSNull null]]) self.lastName = @"";
    else self.lastName = lName;
    
    if (!anEmail || [anEmail isEqual:[NSNull null]]) self.email = @"";
    else self.email = anEmail;
    
    self.imageURL = URL;

    return self;
}

-(UIImage *)getProfileImage
{
    if (!self.imageURL || [self.imageURL isEqual:[NSNull null]] || [self.imageURL isEqualToString:@""]) {
        
        UIImage* img = [UIImage imageNamed:NSLocalizedString(@"DEFAULT_USER_PROFILE", nil)];

        return img;
    }
    else
    {
        UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]];
        
        return img;
    }
}

-(NSString *)getUserID
{
    return self.userID.copy;
}

-(void)setAccountType:(NSString *)type
{
    if(!type) return;
    
    type = type.lowercaseString;
    
    if([type isEqualToString:kHOST_ACCOUNT]){
        accountType = Account_Host;
    }
    else if ([type isEqualToString:kATTENDEE_ACCOUNT]){
        accountType = Account_Attendee;
    }
    else accountType = Account_Default;
}

-(void)clear
{
    self.firstName = NSLocalizedString(@"DEFAULT_NO_ACCOUNT_NAME", nil);
    
    self.profileImage = [UIImage imageNamed:NSLocalizedString(@"DEFAULT_KEY_USER_PROFILE", nil)];
    
    self.lastName = nil;
    self.email = nil;
    self.imageURL = nil;
    
    NSLog(@"Account Cleared");
}

@end
