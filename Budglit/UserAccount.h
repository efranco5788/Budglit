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
@property (NS_NONATOMIC_IOSONLY, getter=getProfileImage, strong) UIImage *profileImage;

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName;

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL;

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL andEmail:(NSString*)anEmail;

-(instancetype)initWithFirstName:(NSString*)fName andLastName:(NSString*)lName andProfileImage:(NSString*)URL andEmail:(NSString*)anEmail andID:(NSString*)sID NS_DESIGNATED_INITIALIZER;

-(NSString*)getUserID;

-(void)setAccountType:(NSString*)type;

-(void)clear;

@end
