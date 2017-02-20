//
//  PSFacebookViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/26/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "SocialMediaViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface PSFacebookViewController : SocialMediaViewController

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end
