//
//  LoginPageViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginPageDelegate <NSObject>
@optional
-(void)loginSucessful;
@end

@interface LoginPageViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<LoginPageDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *loginPageBackground;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *FNameField;
@property (weak, nonatomic) IBOutlet UITextField *LNameField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *passwordVisibility;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupButtonBottom_Constraint;

- (IBAction)passwordVisibilityPressed:(id)sender;

- (IBAction)loginButtonPressed:(UIButton *)sender;

- (IBAction)signUpButtonPressed:(UIButton *)sender;

- (void) setupPasswordResetController;

- (void)toggleNameFields;



@end
