//
//  DealDetailViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialMedia/SocialMediaViewController.h"

@class AppDelegate;
@class Deal;
@class DealViewModel;
@class TwitterViewController;
@class PSFacebookViewController;
@class InstagramViewController;

@interface DealDetailViewController : UIViewController<SocialMediaViewDelegate>

@property (strong, nonatomic) DealViewModel* dealViewModel;
@property (weak, nonatomic) IBOutlet UIView* socialMediaContainer;
@property (strong, nonatomic) UIPageViewController* SMPageViewController;
@property (strong, nonatomic) TwitterViewController* twitterViewController;
@property (strong, nonatomic) PSFacebookViewController* fbViewController;
@property (strong, nonatomic) InstagramViewController* instaViewController;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imgActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView* descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *venueLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UILabel *budgetLbl;
@property (strong, nonatomic) IBOutlet UIImageView* venueImage;
@property (strong, nonatomic) IBOutlet UIImageView *addressImage;
@property (strong, nonatomic) IBOutlet UIImageView *phoneImage;

@property (weak, nonatomic) IBOutlet UINavigationBar *socialMediaNavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem* socialMediaNavItem;

@property (strong, nonatomic) UITextView* addressTextView;
@property (strong, nonatomic) UITextView* phoneNumberTextView;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *twitterViewGesture;
@property (strong, nonatomic) UITapGestureRecognizer* tapTwitterView;
@property (strong, nonatomic) UITapGestureRecognizer* tapDealView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *SMContainerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *SMContainerBtmConstraint;

@property (strong, nonatomic) NSLayoutConstraint* adjustedTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint* adjustedBottomConstraint;

-(void)setDealSelected:(Deal*)aDeal;

-(void) cancelButton_pressed:(UIBarButtonItem*)sender;

-(IBAction)panDetect:(id)sender;

-(IBAction)tapDetect:(UITapGestureRecognizer*)sender;

@property (NS_NONATOMIC_IOSONLY, getter=getOriginalPosition) CGRect originalPosition;



@end
