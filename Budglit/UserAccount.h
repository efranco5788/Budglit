//
//  UserAccount.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/15/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject <NSCoding>

@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) UIImage* profileImage;

+(UserAccount*) currentSignedUser;

-(id)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName;

-(id)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL;

-(id)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL andEmail:(NSString*)anEmail;

-(id)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL andEmail:(NSString*)anEmail andSessionID:(NSString*)sID;

-(UIImage*)getProfileImage;

-(void)clear;

@end
