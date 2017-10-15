//
//  LoginPageViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "LoginPageViewController.h"
#import "AccountManager.h"
#import "AppDelegate.h"

#define EMAIL_TF 1
#define PASSWORD_TF 2
#define EMAIL_CONFIRMATION_TF 7
#define FIRST_NAME_TF 3
#define LAST_NAME_TF 4
#define EMAIL_FIELD @"user_email"
#define PASSWORD_FIELD @"user_password"
#define EMAIL_TEXTFIELD_PLACEHOLDER @"*Email"
#define PASSWORD_TEXTFIELD_PLACEHOLDER @"*Password"
#define FIRST_NAME_TEXTFIELD_PLACEHOLDER @"*First Name"
#define LAST_NAME_TEXTFIELD_PLACEHOLDER @"Last Name"
#define USERNAME_IMAGE @"icon_username.png"
#define PASSWORD_IMAGE @"icon_lock.png"


@interface LoginPageViewController () <AccountManagerDelegate>
{
    NSLayoutConstraint* kbConstraint;
    NSLayoutConstraint* newConstraint;
    CGRect initialLoginButtonFrame;
    CGRect initialSignupButtonFrame;
    BOOL keyboardIsVisible;
}

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self refreshInterface];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    UIColor* primaryColor = [UIColor colorWithRed:44.0f/255.0f
                                            green:83.0f/255.0f
                                             blue:143.0f/255.0f
                                            alpha:1.0f];
    
    gradient.colors = @[(id)primaryColor.CGColor, (id)[UIColor whiteColor].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];

    initialLoginButtonFrame = self.loginButton.frame;
    initialSignupButtonFrame = self.signupButton.frame;

    UIImageView* imgUsrView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgUsrView.image = [UIImage imageNamed:USERNAME_IMAGE];
    
    UIImageView* imgPasswrdView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgPasswrdView.image = [UIImage imageNamed:PASSWORD_IMAGE];

    (self.emailField).leftViewMode = UITextFieldViewModeAlways;
    (self.emailField).leftView = imgUsrView;
    
    
    (self.passwordField).leftViewMode = UITextFieldViewModeAlways;
    (self.passwordField).leftView = imgPasswrdView;
    
    kbConstraint.active = NO;
    newConstraint.active = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)refreshInterface{
    
    UIColor *color = [UIColor whiteColor];
    
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        (self.emailField).font = font;
    }
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:color}];
        (self.passwordField).font = font;
    }
    
    [self.passwordField setSecureTextEntry:YES];
    
    if ([self.FNameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.FNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: color}];
        (self.FNameField).font = font;
    }
    
    if ([self.LNameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.LNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName: color}];
        (self.LNameField).font = font;
    }
    
    [self.passwordVisibility setSelected:YES];
}

-(void)refreshInterface:(UITextField*)field {
    if (field) field.text = @"";
}


#pragma mark -
#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    
    textField.adjustsFontSizeToFitWidth = YES;
}
 

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    /*
    if ([textField.text isEqualToString:@""]) {
        if (textField.tag == EMAIL_TF) {
            textField.placeholder = EMAIL_TEXTFIELD_PLACEHOLDER;
        }
        else if (textField.tag == PASSWORD_TF){
            textField.placeholder = PASSWORD_TEXTFIELD_PLACEHOLDER;
        }
        else if (textField.tag == FIRST_NAME_TF){
            textField.placeholder = FIRST_NAME_TEXTFIELD_PLACEHOLDER;
        }
        else if (textField.tag == LAST_NAME_TF){
            textField.placeholder = LAST_NAME_TEXTFIELD_PLACEHOLDER;
        }
    }
    */
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


-(void)setupPasswordResetController
{
    NSString* resetPasswordTitle = @"Reset Password";
    NSString* resetPasswordMessage = @"Please enter your email and you will receieve a password reset confirmation.";
    NSString* doneActionTitle = @"Done";
    
    UIAlertController* resetPassword = [UIAlertController alertControllerWithTitle:resetPasswordTitle message:resetPasswordMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [resetPassword addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = EMAIL_CONFIRMATION_TF;
        textField.placeholder = EMAIL_TEXTFIELD_PLACEHOLDER;
        textField.delegate = self;
    }];
    
    UIAlertAction* doneAction = [UIAlertAction actionWithTitle:doneActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField* email = resetPassword.textFields[0];
        
        if (email.text.length == 0) {
            [self setupPasswordResetController];
        }
        else
        {
            
        }
    }];
    
    [resetPassword addAction:doneAction];
    
    [self presentViewController:resetPassword animated:YES completion:nil];
}

-(void)toggleNameFields
{
    if ((self.FNameField).hidden) {
        [self.FNameField setHidden:NO];
        [self.LNameField setHidden:NO];
    }
}

#pragma mark - Account Manager delegate
-(void)loginSucessful
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.accountManager).delegate = self;

    [appDelegate.accountManager saveCredentials];
}

-(void)loginFailedWithError:(NSError *)error
{
    NSString* failedTitle = @"Login Failed";
    NSString* failedMessage = @"Invalid username or password";
    NSString* retry = @"Retry";
    NSString* resetPassword = @"Reset Password";
    
    UIAlertAction* actionRetry = [UIAlertAction actionWithTitle:retry style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self refreshInterface:self.passwordField];
    }];
    
    UIAlertAction* actionResetPassword = [UIAlertAction actionWithTitle:resetPassword style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setupPasswordResetController];
    }];
    
    UIAlertController* failedAlert = [UIAlertController alertControllerWithTitle:failedTitle message:failedMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [failedAlert addAction:actionRetry];
    [failedAlert addAction:actionResetPassword];
    
    [self presentViewController:failedAlert animated:YES completion:nil];
}

-(void)signupSucessfully
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    (appDelegate.accountManager).delegate = self;
    
    [appDelegate.accountManager saveCredentials];
}

-(void)signupFailedWithError:(NSError *)error
{
    
}

-(void)credentialsSaved
{
    NSLog(@"Credentials Saved...");
    [self.delegate loginSucessful];
}

#pragma mark - Keyboard Notifications
-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = notification.userInfo;
    
    CGSize keyboardSize = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    double kbAnimationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect viewableFrame = CGRectInset(self.view.frame, 0, CGRectGetHeight(keyboardEndFrame));
    
    
    if (!CGRectContainsRect(viewableFrame, self.signupButton.frame)) {
        
        kbConstraint = [self.loginPageBackground.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0];
        
        newConstraint = [self.signupButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-(keyboardSize.height)];
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:(kbAnimationDuration / 2) delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            [self.view layoutIfNeeded];
            
            self.signupButtonBottom_Constraint.active = NO;
            
            kbConstraint.active = YES;
            
            newConstraint.active = YES;
            
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
        }];
        
    }

}

-(void)keyboardWillHide:(NSNotification *)notification
{
    //NSDictionary* keyboardInfo = [notification userInfo];
    
    newConstraint.active = NO;
    
    //self.signupButtonBottom_Constraint.active = YES;
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    NSString* user_email = self.emailField.text;
    NSString* user_password = self.passwordField.text;
    
    if ([user_email  isEqualToString:@""] || [user_password  isEqualToString:@""]) {
        NSLog(@"Empty");
    }
    else{
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        
        NSDictionary* credentials = @{EMAIL_FIELD: user_email, PASSWORD_FIELD: user_password};
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        (appDelegate.accountManager).delegate = self;
        
        [appDelegate.accountManager login:credentials];
        
    }
    
}

- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    [self toggleNameFields];
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    NSString* user_email = self.emailField.text;
    
    NSString* user_password = self.passwordField.text;
    
    if ([user_email  isEqualToString:@""] || [user_password  isEqualToString:@""]) {
        NSLog(@"Empty");
    }
    else{
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        
        NSDictionary* credentials = @{EMAIL_FIELD: user_email, PASSWORD_FIELD: user_password};
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        (appDelegate.accountManager).delegate = self;
        
        [appDelegate.accountManager signup:credentials];
    }
    
}

- (IBAction)passwordVisibilityPressed:(id)sender {
    
    if (self.passwordVisibility.isSelected) {
        [self.passwordField setSecureTextEntry:NO];
        [self.passwordVisibility setSelected:NO];
    }
    else{
        [self.passwordField setSecureTextEntry:YES];
        [self.passwordVisibility setSelected:YES];
    }
}
@end
