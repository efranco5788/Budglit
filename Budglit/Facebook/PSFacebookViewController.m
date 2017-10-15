//
//  PSFacebookViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/26/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "PSFacebookViewController.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface PSFacebookViewController ()

@end

@implementation PSFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginButton = [[FBSDKLoginButton alloc] init];
    
    self.loginButton.readPermissions =
    @[@"public_profile", @"email", @""];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.loginButton setHidden:YES];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    NSLog(@"%d", [appDelegate.fbManager isLoggedIn]);
    
    if (![appDelegate.fbManager isLoggedIn]) {
        
        [self.loginButton setHidden:NO];
        
        [super viewDidLayoutSubviews];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
