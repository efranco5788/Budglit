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

#define USERNAME_IMAGE @"icon_username.png"
#define PASSWORD_IMAGE @"icon_lock.png"
#define EMAIL_FIELD @"email"
#define PASSWORD_FIELD @"password"
#define FIRST_NAME_FIELD @"firstName"
#define LAST_NAME_FIELD @"lastName"
#define EMAIL_TEXTFIELD_PLACEHOLDER @"*Email"
#define PASSWORD_TEXTFIELD_PLACEHOLDER @"*Password"
#define CONFIRM_PASSWORD_TEXTFIELD_PLACEHOLDER @"*Confirm Password"
#define FIRST_NAME_TEXTFIELD_PLACEHOLDER @"First Name"
#define LAST_NAME_TEXTFIELD_PLACEHOLDER @"Last Name"


@interface LoginPageViewController () <AccountManagerDelegate>
{
    CGRect initialLoginButtonFrame;
    CGRect initialSignupButtonFrame;
}

@end

@implementation LoginPageViewController

+(BOOL)validateEmailAddress:(NSString *)email
{
    if(!email) return NO;
    
    NSRegularExpression* regEx = [[NSRegularExpression alloc] initWithPattern:@"([A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{1,})" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSUInteger regExpResult = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, email.length)];
    
    return (regExpResult == 0) ? NO : YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self refreshInterface];
    
    self.signupButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    
    gradient.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    UIColor* primaryColor = [appDelegate getPrimaryColor];
    
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

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)refreshInterface
{
    UIColor *color = [UIColor whiteColor];
    
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    UIFont* italicFont = [UIFont fontWithName:@"HelveticaNeue-Italic" size:17.0f];
    
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:EMAIL_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName: color}];
        (self.emailField).font = font;
    }
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:PASSWORD_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName:color}];
        (self.passwordField).font = font;
    }
    
    if([self.confirmPasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]){
        self.confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:CONFIRM_PASSWORD_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName:color}];
        (self.confirmPasswordField).font = font;
    }
    
    [self.passwordField setSecureTextEntry:YES];
    [self.confirmPasswordField setSecureTextEntry:YES];
    
    if ([self.FNameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.FNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:FIRST_NAME_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName: color}];
        (self.FNameField).font = italicFont;
    }
    
    if ([self.LNameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.LNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LAST_NAME_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName: color}];
        (self.LNameField).font = italicFont;
    }
    
    [self.passwordVisibility setSelected:YES];
    
    [self.view setNeedsDisplay];
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
    
    if([textField isEqual:self.emailField]) [self.emailField setTextColor:[UIColor whiteColor]];
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
    
    if([textField isEqual:self.emailField])
    {
        NSString* email = self.emailField.text.lowercaseString;
        
        BOOL isValid = [LoginPageViewController validateEmailAddress:email];
        
        if (isValid == NO) {
            [self.emailField setTextColor:[UIColor redColor]];
        }
        else [self.emailField setTextColor:[UIColor whiteColor]];
        
    }
    
    if([textField isEqual:self.confirmPasswordField])
    {
        self.passwordField.text = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        self.confirmPasswordField.text = [self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(![self.confirmPasswordField.text isEqualToString:self.passwordField.text])
        {
            [self.passwordMismatch_Img setHidden:NO];
        }
        else [self.passwordMismatch_Img setHidden:YES];
    }
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
        [self.confirmPasswordField setHidden:NO];
        [self.FNameField setHidden:NO];
        [self.LNameField setHidden:NO];
    }
}

-(void)toggleButtonConstraintsActivate:(BOOL)enable
{
    NSLayoutConstraint* constraints[2];
    constraints[0] = self.signupButtonBottom_Constraint;
    constraints[1] = self.signupButtonBottom_VerticalConstraint;
    
    if(enable == YES)[self.view addConstraints:[NSArray arrayWithObjects:constraints count:2]];
    else [self.view removeConstraints:[NSArray arrayWithObjects:constraints count:2]];

}

-(void)constructButtonNewContraintsKeyboardInfo:(NSDictionary *)info
{
    if(!info) return;
    
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.kbConstraint = [self.loginPageBackground.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0];
    
    self.viewConstraint = [self.signupButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-(keyboardSize.height)];

}

#pragma mark -
#pragma mark - Account Manager delegate
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

-(void)signupFailedWithError:(NSError *)error
{
    
}

#pragma mark -
#pragma mark - Keyboard Notifications
-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = notification.userInfo;
    
    CGRect keyboardEndFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect viewableFrame = CGRectInset(self.view.frame, 0, CGRectGetHeight(keyboardEndFrame));
    
    if (!CGRectContainsRect(viewableFrame, self.signupButton.frame)) {
        
        if (!self.viewConstraint) {
            [self constructButtonNewContraintsKeyboardInfo:keyboardInfo];
        }
        
        [self.view layoutIfNeeded];
        
        [self toggleButtonConstraintsActivate:NO];
        
        [self.view layoutIfNeeded];
        
        NSLayoutConstraint* constraints[2];
        constraints[0] = self.kbConstraint;
        constraints[1] = self.viewConstraint;
        [self.view addConstraints:[NSArray arrayWithObjects:constraints count:2]];
        
        [self.view layoutIfNeeded];
    }

}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.view layoutIfNeeded];

    NSLayoutConstraint* constraints[2];
    
    constraints[0] = self.kbConstraint;
    constraints[1] = self.viewConstraint;

    NSArray* constraintArray = [NSArray arrayWithObjects:constraints[0], constraints[1], nil];
    
    if(constraintArray && constraintArray.count > 0){
        
        [self.view removeConstraints:constraintArray];
        
        [self toggleButtonConstraintsActivate:YES];
        
    }
    
    [self.view layoutIfNeeded];
}

#pragma mark -
#pragma mark - User Login Methods
- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    NSString* user_email = self.emailField.text;
    NSString* user_password = self.passwordField.text;
    
    if ([user_email  isEqualToString:@""] || [user_password  isEqualToString:@""]) NSLog(@"Empty");
    else{
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        (appDelegate.accountManager).delegate = self;
        
        [appDelegate.accountManager login:@{EMAIL_FIELD: user_email, PASSWORD_FIELD: user_password} shouldSaveCredentials:YES addCompletion:^(BOOL success) {
            
            if(success){
                
                NSLog(@"Login Sucessful");
                
                [self.delegate loginSucessful];
            }
            
        }];
        
    }
    
}


#pragma mark -
#pragma mark - User Signup Methods
- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    if(self.FNameField.hidden){
        [self toggleNameFields];
    }
    else{
        
        for (UITextField* textField in self.fieldCollection) textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([self.emailField.text  isEqualToString:@""] || [self.passwordField.text  isEqualToString:@""]) {
            
            UIAlertController* emptyFieldsAlert = [UIAlertController alertControllerWithTitle:@"Incomplete Information" message:@"Please provide atleast an email and password" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            
            [emptyFieldsAlert addAction:ok];
            
            [self presentViewController:emptyFieldsAlert animated:YES completion:nil];
            
        }
        else{
            
            self.emailField.text = self.emailField.text.lowercaseString;
            
            if([LoginPageViewController validateEmailAddress:self.emailField.text]){
                
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                
                AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
                
                (appDelegate.accountManager).delegate = self;
                
                [appDelegate.accountManager signup:@{EMAIL_FIELD: self.emailField.text, PASSWORD_FIELD: self.passwordField.text, FIRST_NAME_FIELD: self.FNameField.text, LAST_NAME_FIELD: self.LNameField.text} shouldSaveCredentials:YES addCompletion:^(id object) {
                    
                    if([object isKindOfClass:[UIAlertController class]])
                    {
                        UIAlertController* alert = (UIAlertController*) object;
                        
                        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        
                        [alert addAction:okAction];
                        
                        [self presentViewController:alert animated:YES completion:^{
                            [self refreshInterface:self.emailField];
                        }];
                    }
                    
                }]; // End of Account Manager signup call
                
            }
            else{
                
                UIAlertController* emptyFieldsAlert = [UIAlertController alertControllerWithTitle:@"Invalid Email" message:@"Please provide a valid email" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                
                [emptyFieldsAlert addAction:ok];
                
                [self presentViewController:emptyFieldsAlert animated:YES completion:nil];
                
            }
            
        } // End of else statement, attempt to sign up new user
        
    }
    
}

- (IBAction)passwordVisibilityPressed:(id)sender {
    
    if (self.passwordVisibility.isSelected) {
        [self.passwordField setSecureTextEntry:NO];
        [self.confirmPasswordField setSecureTextEntry:NO];
        [self.passwordVisibility setSelected:NO];
    }
    else{
        [self.passwordField setSecureTextEntry:YES];
        [self.confirmPasswordField setSecureTextEntry:YES];
        [self.passwordVisibility setSelected:YES];
    }
}
@end
