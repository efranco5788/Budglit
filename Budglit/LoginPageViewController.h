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

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIImageView *passwordMismatch_Img;
@property (weak, nonatomic) IBOutlet UITextField *FNameField;
@property (weak, nonatomic) IBOutlet UITextField *LNameField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *lbl_invalidEmail;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *fieldCollection;
@property (strong, nonatomic) IBOutlet UIButton *passwordVisibility;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *signupButtonBottom_VerticalConstraint;
@property (strong, nonatomic) NSLayoutConstraint* kbConstraint; // Keyboard Constraint
@property (strong, nonatomic) NSLayoutConstraint* viewConstraint;

+ (BOOL)validateEmailAddress:(NSString*)email;

- (IBAction)passwordVisibilityPressed:(id)sender;

- (IBAction)loginButtonPressed:(UIButton *)sender;

- (IBAction)signUpButtonPressed:(UIButton *)sender;

- (void)setupPasswordResetController;

- (void)toggleNameFields:(BOOL)shouldDisplay;

- (void)toggleButtonConstraintsActivate:(BOOL)enable;

- (void)constructButtonNewContraintsKeyboardInfo:(NSDictionary*)info;

@end
