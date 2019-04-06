//
//  LoginPageViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//
#import "LoginPageViewController.h"
#import "AccountManager.h"
#import "UserAccount.h"
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
    
    [self displayInvalidEmailMessage:NO];
    
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
    
    [self clearTextFields];
    
    [self toggleNameFields:NO];

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

-(void)displayInvalidEmailMessage:(BOOL)shouldDisplay
{
    [self.lbl_invalidEmail setHidden:!shouldDisplay];
}

-(void)refreshInterface
{
    UIColor *color = [UIColor whiteColor];

    UIFont* italicFont = [UIFont fontWithName:@"HelveticaNeue-Italic" size:15.0f];
    
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:EMAIL_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName: color}];
        (self.emailField).font = italicFont;
    }
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:PASSWORD_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName:color}];
        (self.passwordField).font = italicFont;
    }
    
    if([self.confirmPasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]){
        self.confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:CONFIRM_PASSWORD_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName:color}];
        (self.confirmPasswordField).font = italicFont;
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

-(void)clearTextField:(UITextField*)field
{
    if (field) field.text = @"";
}

-(void)clearTextFields
{
    for (UITextField* field in self.textFields) {
        field.text = @"";
    };
}


#pragma mark -
#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    
    textField.adjustsFontSizeToFitWidth = YES;
    
    if(textField.tag == 0){
        
        [textField setTextColor:[UIColor whiteColor]];
        
    }
    
    if(textField.tag == 2){
        [textField setTextColor:[UIColor whiteColor]];
        [self.passwordMismatch_Img setHidden:YES];
    }
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
        
        return;
        
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
        
        return;
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
        textField.text = self.emailField.text;
        textField.delegate = self;
        textField.textColor = [UIColor blackColor];
    }];

    UIAlertAction* doneAction = [UIAlertAction actionWithTitle:doneActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        if(resetPassword.textFields[0].text.length == 0) {
            [self setupPasswordResetController];
        }
        
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [resetPassword addAction:doneAction];
    [resetPassword addAction:cancelAction];
    
    [self presentViewController:resetPassword animated:YES completion:nil];
}

-(void)toggleNameFields:(BOOL)shouldDisplay
{
    if(shouldDisplay)
    {
        [self.confirmPasswordField setHidden:NO];
        [self.FNameField setHidden:NO];
        [self.LNameField setHidden:NO];
    }
    else{
        
        [self.confirmPasswordField setHidden:YES];
        [self.FNameField setHidden:YES];
        [self.LNameField setHidden:YES];
    }
}

-(void)toggleDimmerOn:(BOOL)activate
{
    if(activate == YES){
        
        UIView* dimmer = [[UIView alloc] initWithFrame:self.view.bounds];
        
        [dimmer setTag:100];
        
        [dimmer setBackgroundColor:[UIColor blackColor]];
        
        [dimmer setAlpha:0.4];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [activity setCenter:self.view.center];
        
        [dimmer addSubview:activity];
        
        [self.view addSubview:dimmer];
        
        [activity startAnimating];
        
    }
    else{
        
        UIView* dimmer = (UIView*) [self.view viewWithTag:100];
        
        if(dimmer) [dimmer removeFromSuperview];
    }
}

-(void)toggleButtonConstraintsActivate:(BOOL)enable
{
    NSLayoutConstraint* constraints[1];
    
    //constraints[0] = self.signupButtonBottom_Constraint;
    constraints[0] = self.signupButtonBottom_VerticalConstraint;
    
    if(enable == YES)[self.view addConstraints:[NSArray arrayWithObjects:constraints count:1]];
    else [self.view removeConstraints:[NSArray arrayWithObjects:constraints count:1]];

}

-(void)constructButtonNewContraintsKeyboardInfo:(NSDictionary *)info
{
    if(!info) return;
    
    if(self.kbConstraint && self.viewConstraint)
    {
        NSLayoutConstraint* constraints[2];
        
        constraints[0] = self.kbConstraint;
        constraints[1] = self.viewConstraint;

        [self.view removeConstraints:[NSArray arrayWithObjects:constraints count:2]];
        
        self.kbConstraint = nil;
        self.viewConstraint = nil;
        
    }
    
    
    CGSize keyboardSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.kbConstraint = [self.loginPageBackground.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0];
    
    self.viewConstraint = [self.signupButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-(keyboardSize.height)];
    
    
}

#pragma mark -
#pragma mark - Keyboard Notifications
-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = notification.userInfo;
    
    [self constructButtonNewContraintsKeyboardInfo:keyboardInfo];
    
    [self.view layoutIfNeeded];
    
    [self toggleButtonConstraintsActivate:NO];
    
    [self.view layoutIfNeeded];
    
    NSLayoutConstraint* constraints[2];
    constraints[0] = self.kbConstraint;
    constraints[1] = self.viewConstraint;
    
    [self.view addConstraints:[NSArray arrayWithObjects:constraints count:2]];
    
    [self.view layoutIfNeeded];
    
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
    
    if ([self.emailField.text  isEqualToString:@""]){
        
        [self displayInvalidEmailMessage:YES];
 
    }
    else{
        
        NSString* user_email = [self.emailField.text lowercaseString];
        
        BOOL isValid = [LoginPageViewController validateEmailAddress:user_email];
        
        if(isValid == NO){
            
            [self displayInvalidEmailMessage:YES];
            
        }
        else{
            
            [self displayInvalidEmailMessage:NO];
            
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            
            NSString* user_password = self.passwordField.text;
            
            if([self.passwordField.text  isEqualToString:@""]){
                
                NSString* failedTitle = @"Password Field";
                NSString* failedMessage = @"Password field can not be empty";
                
                UIAlertAction* done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
                
                UIAlertController* failedAlert = [UIAlertController alertControllerWithTitle:failedTitle message:failedMessage preferredStyle:UIAlertControllerStyleAlert];
                
                [failedAlert addAction:done];
                
                [self presentViewController:failedAlert animated:YES completion:nil];
                
            }
            else{
                
                [self toggleDimmerOn:YES];
                
                AccountManager* accountManager = [AccountManager sharedAccountManager];
                
                [accountManager setDelegate:self];
                
                [accountManager login:@{EMAIL_FIELD: user_email, PASSWORD_FIELD: user_password} shouldSaveCredentials:YES addCompletion:^(BOOL success) {
                    
                    [self toggleDimmerOn:NO];
                    
                    if(success == YES){
                        
                        NSLog(@"Login Sucessful");
                        
                        [self.delegate loginSucessful];
                        
                    }
                    else{
                        
                         NSString* failedTitle = @"Login Failed";
                         NSString* failedMessage = @"Invalid username or password";
                         NSString* retry = @"Retry";
                         NSString* resetPassword = @"Reset Password";
                         
                         UIAlertAction* actionRetry = [UIAlertAction actionWithTitle:retry style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                         [self clearTextField:self.passwordField];
                         }];
                         
                         UIAlertAction* actionResetPassword = [UIAlertAction actionWithTitle:resetPassword style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                         [self setupPasswordResetController];
                         }];
                         
                         UIAlertController* failedAlert = [UIAlertController alertControllerWithTitle:failedTitle message:failedMessage preferredStyle:UIAlertControllerStyleAlert];
                         
                         [failedAlert addAction:actionRetry];
                         [failedAlert addAction:actionResetPassword];
                         
                         [self presentViewController:failedAlert animated:YES completion:nil];
                        
                        
                    }
                    
                }];
                
            }
            
            
        }
        

        
    }
    
}


#pragma mark -
#pragma mark - User Signup Methods
- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    if(self.FNameField.isHidden)
    {
        [self toggleNameFields:YES];
    }
    else
    {
        for (UITextField* textField in self.fieldCollection) textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([self.emailField.text  isEqualToString:@""] || [self.passwordField.text  isEqualToString:@""]) {
            
            UIAlertController* emptyFieldsAlert = [UIAlertController alertControllerWithTitle:@"Incomplete Information" message:@"Please provide an email and password minimum" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            
            [emptyFieldsAlert addAction:ok];
            
            [self presentViewController:emptyFieldsAlert animated:YES completion:nil];
            
        }
        else if ([self.confirmPasswordField.text isEqualToString:@""]) {
            
            UIColor *color = [UIColor redColor];
            
            self.confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:CONFIRM_PASSWORD_TEXTFIELD_PLACEHOLDER attributes:@{NSForegroundColorAttributeName:color}];
            
        }
        else{
            
            NSString* email = self.emailField.text.lowercaseString;
            
            BOOL isValid = [LoginPageViewController validateEmailAddress:email];
            
            if(isValid == YES){
                
                NSString* fName = self.FNameField.text.lowercaseString;
                
                NSString* lName = self.LNameField.text.lowercaseString;
                
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                
                AccountManager* accountManager = [AccountManager sharedAccountManager];
                
                accountManager.delegate = self;
                
                [self toggleDimmerOn:YES];
                
                [accountManager signup:@{EMAIL_FIELD: email, PASSWORD_FIELD: self.passwordField.text, FIRST_NAME_FIELD: fName, LAST_NAME_FIELD: lName} shouldSaveCredentials:YES addCompletion:^(id object) {
                    
                    [self toggleDimmerOn:NO];
                    
                    if([object isKindOfClass:[UIAlertController class]])
                    {
                        UIAlertController* alert = (UIAlertController*) object;
                        
                        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        
                        [alert addAction:okAction];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else if ([object isKindOfClass:[UserAccount class]])
                    {
                        NSLog(@"Login Sucessful");
                        
                        [self.delegate loginSucessful];
                        
                    }
                    
                }]; // End of Account Manager signup call
                
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


#pragma mark -
#pragma mark - Account Manager delegate
-(void)networkRequestFailedWithError:(UIAlertController *)alertView
{
    [self toggleDimmerOn:NO];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
