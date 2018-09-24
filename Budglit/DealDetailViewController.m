//
//  DealDetailViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DealDetailViewController.h"
#import "AppDelegate.h"
#import "DatabaseEngine.h"
#import "Deal.h"
#import "PSFacebookViewController.h"
#import "TwitterViewController.h"
#import "PSAllDealsTableViewController.h"
#import "PSInstagramViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UNWIND_TO_ALL_CURRENT_DEALS @"unwindToDeals"
#define ALLDEALS_VC_SB_ID @"PSAllDealsTableViewController"
#define LAST_INDEX 2

@interface DealDetailViewController ()<UIGestureRecognizerDelegate, TwitterViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, PSAllDealsTableViewControllerDelegate, DatabaseManagerDelegate>
{
    CGRect originalTwitterView;
    UIView* backgroundDimmerMainView;
    BOOL isSocialMediaViewInView;
    CGRect tableCellPosition;
}
@end



@implementation DealDetailViewController
@synthesize descriptionTextView, addressTextView, venueLbl, distanceLbl, phoneNumberTextView, addressText, phoneText, venueImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.contentInset = UIEdgeInsetsMake(0, 0, 7, 0);
    
    (self.descriptionTextView).text = self.descriptionText;
    
    self.distanceLbl.text = self.distanceText;
    
    self.venueLbl.text = self.venueName;
    
    self.descriptionTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.addressTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.addressImage.frame.origin.x, self.addressImage.frame.origin.y, 0, 0)];
    
    [self.addressTextView setEditable:NO];
    
    [self.addressTextView setOpaque:NO];
    
    (self.addressTextView).alpha = 0;
    
    (self.addressTextView.layer).borderWidth = 0.5;
    
    (self.addressTextView.layer).cornerRadius = 5.0;
    
    (self.addressTextView).text = self.addressText;
    
    self.addressTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    
    self.addressTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    (self.phoneNumberTextView).text = self.phoneText;
    
    self.phoneNumberTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.phoneImage.frame.origin.x, self.phoneImage.frame.origin.y, 0, 0)];
    
    [self.phoneNumberTextView setEditable:NO];
    
    [self.phoneNumberTextView setOpaque:NO];
    
    (self.phoneNumberTextView).alpha = 0;
    
    (self.phoneNumberTextView.layer).borderWidth = 0.5;
    
    (self.phoneNumberTextView.layer).cornerRadius = 5.0;
    
    self.phoneNumberTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    
    self.phoneNumberTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.SMPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    // Create the Social Media Container Frame
    CGRect barFrame = self.socialMediaNavBar.frame;
    CGRect containerBounds = (self.socialMediaContainer).bounds;
    CGRect newInsetFrame = CGRectInset(containerBounds, barFrame.origin.x, barFrame.origin.y);
    CGRect newFrame = CGRectOffset(newInsetFrame, barFrame.origin.x, barFrame.size.height);

    (self.SMPageViewController.view).frame = newFrame;
    
    [self.SMPageViewController.view setClipsToBounds:YES];

    (self.SMPageViewController).dataSource = self;
    (self.SMPageViewController).delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.image = nil;
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] init];
    
    backButton.title = @"Back";
    
    backButton.target = self;
    
    backButton.action = @selector(cancelButton_pressed:);
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationItem.title = self.venueName;
    
    isSocialMediaViewInView = NO;

    
    if (!self.twitterViewController) {
        [self constructTwitterView];
    }
    
    NSArray* viewCntrlors = @[self.twitterViewController];
    
    [self.SMPageViewController setViewControllers:viewCntrlors direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self.SMPageViewController addChildViewController:self.twitterViewController];
    
    (self.SMPageViewController.view).backgroundColor = [UIColor clearColor];
    
    [self addChildViewController:self.SMPageViewController];
    [self.socialMediaContainer addSubview:self.SMPageViewController.view];
    
    [self addAllTapGestures];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    CGPoint topSetScroll = CGPointMake(0, -self.descriptionTextView.contentInset.top);
    
    [self.descriptionTextView setContentOffset:topSetScroll animated:NO];
    
    __block CATransition* transition = [CATransition animation];
    
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    
    [self.venueImage.layer addAnimation:transition forKey:nil];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    dispatch_queue_t background_queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    
    //Test response time 
    CFTimeInterval startTime = CACurrentMediaTime();
    
    dispatch_async(background_queue, ^{
        
        NSLog(@"%@", self.dealSelected.imgStateObject.imagePath);
        
        // Check if image is cached in memory
        [appDelegate.databaseManager managerFetchCachedImageForKey:self.dealSelected.imgStateObject.imagePath addCompletion:^(UIImage *cachedImage) {
            
            if (cachedImage) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CFTimeInterval elapsed = CACurrentMediaTime() - startTime;
                    
                    NSLog(@"Time for memory cache %f", elapsed);
                    
                    //self.image = cachedImage;
                    
                    (self.venueImage).image = cachedImage;
                    
                    [self.imgActivityIndicator setHidden:YES];

                });
                
            }
            else{
                
                [appDelegate.databaseManager managerFetchPersistentStorageCachedImageForKey:self.dealSelected.imgStateObject.imagePath deal:self.dealSelected addCompletion:^(UIImage *persistentStorageImg) {
                    
                    // check if image is in Persistent Storage Caches
                    if(persistentStorageImg){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            CFTimeInterval elapsed = CACurrentMediaTime() - startTime;
                            
                            NSLog(@"Time for persistent storage cache %f", elapsed);
                            
                            //self.image = persistentStorageImg;
                            
                            (self.venueImage).image = persistentStorageImg;
                            
                            [self.imgActivityIndicator setHidden:YES];
                            
                        });
                        
                        
                    }
                    else{
                        
                        [appDelegate.databaseManager managerStartDownloadImageFromURLString:self.dealSelected.imgStateObject.imagePath forDeal:self.dealSelected addCompletion:^(UIImage *imageResponse) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                CFTimeInterval elapsed = CACurrentMediaTime() - startTime;
                                
                                NSLog(@"Time for http request %f", elapsed);
                                
                                (self.venueImage).image = imageResponse;
                                
                                [self.imgActivityIndicator setHidden:YES];

                            });
                            
                        }];
                        
                    } // End of Web download of image
                    
                }]; // End of Persistent Storage Cache fetch
                
            }
            
        }]; // End of Memory Cache fetch
        
    });
    
    CGFloat originalTwitterViewX = self.socialMediaContainer.layer.bounds.origin.x;
    
    CGFloat originalTwitterViewY = (self.view.bounds.size.height - self.socialMediaContainer.layer.bounds.size.height);
    
    // Save the original dimensions of the twitter view
    originalTwitterView = CGRectMake(originalTwitterViewX, originalTwitterViewY, self.view.bounds.size.height, self.view.bounds.size.width);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [appDelegate.databaseManager setDelegate:nil];

}

-(void)setOriginalPosition:(CGRect)frame
{
    tableCellPosition = frame;
}

-(CGRect)getOriginalPosition
{
    return tableCellPosition;
}

#pragma mark -
#pragma mark - Pan Gestures
-(void)panDetect:(id)sender
{
    NSUInteger numOfTouch = [sender numberOfTouches];
    
    if (numOfTouch == 1) {
        
        if (self.twitterViewGesture.state == UIGestureRecognizerStateBegan)
        {
            CGPoint velocity = [self.twitterViewGesture velocityInView:self.view];
            
            if (velocity.y > 0)  [self dragSocialMediaViewDown]; // panning down
            else [self dragSocialMediaViewUp:YES];               // panning up
        }
        
        
    }
}

#pragma mark -
#pragma mark - Tap Gestures Methods
-(void)tapDetect:(UITapGestureRecognizer*)sender
{
    if (sender.view == self.view) {
        if (isSocialMediaViewInView) {
            [self dragSocialMediaViewDown];
        }
    }
    else if (sender.view == self.addressImage)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Address" message:self.addressText preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* gpsAction = [UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            Class mapItemClass = [MKMapItem class];
            
#warning Update method
            if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
                /*
                CLLocationCoordinate2D coord = _dealSelected.getCoordinates;
                
                MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
                
                MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                
                if (self.venueName) {
                    mapItem.name = self.venueName;
                }
                else mapItem.name = @"Destination";
                
                // Set the directions mode to "Walking"
                // Can use MKLaunchOptionsDirectionsModeDriving instead
                NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                // Get the "Current User Location" MKMapItem
                MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                // Pass the current location and destination map items to the Maps app
                // Set the direction mode in the launchOptions dictionary
                [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                               launchOptions:launchOptions];
                */
            }
            
        }];
        
        UIAlertAction* copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIPasteboard* pasteBoard = [UIPasteboard generalPasteboard];
            
            [pasteBoard setPersistent:YES];
            
            pasteBoard.string = self.addressText;
            
        }];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:gpsAction];
        [alert addAction:copyAction];
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (sender.view == self.phoneImage)
    {
        UIAlertController* phoneAlert = [UIAlertController alertControllerWithTitle:@"Telephone Number" message:self.phoneText preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString* phoneNum = [self.phoneText substringFromIndex:1];
            
            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",phoneNum]];

            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                [[UIApplication sharedApplication] openURL:phoneUrl];
            }
        }];
        
        UIAlertAction* copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIPasteboard* pasteBoard = [UIPasteboard generalPasteboard];
            
            [pasteBoard setPersistent:YES];
            
            pasteBoard.string = self.phoneText;
            
        }];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [phoneAlert addAction:defaultAction];
        [phoneAlert addAction:copyAction];
        [phoneAlert addAction:callAction];
        
        [self presentViewController:phoneAlert animated:YES completion:nil];
    }
    else if (sender.view == backgroundDimmerMainView)
    {
        [self dragSocialMediaViewDown];
    }
    else NSLog(@"Twitter View");
}

-(void)addAllTapGestures
{
    UITapGestureRecognizer* tempTapDealView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
    
    UITapGestureRecognizer* tempTapTwitterView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
    
    self.tapDealView = tempTapDealView;
    self.tapTwitterView = tempTapTwitterView;
    
    //[self.view addGestureRecognizer:self.tapDealView];
    
    //[self.view addGestureRecognizer:self.tapTwitterView];
    
    if (self.addressImage) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.addressImage addGestureRecognizer:singleTap];
        [self.addressImage setUserInteractionEnabled:YES];
    }
    
    if (self.phoneImage) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.phoneImage addGestureRecognizer:singleTap];
        [self.phoneImage setUserInteractionEnabled:YES];
        
    }
    
    if (backgroundDimmerMainView) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [backgroundDimmerMainView addGestureRecognizer:singleTap];
        [backgroundDimmerMainView setUserInteractionEnabled:YES];
    }
}

#pragma mark -
#pragma mark - Social Media View Methods
-(void) dragSocialMediaViewUp:(BOOL)darkenBackground
{
    if (isSocialMediaViewInView == NO) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [backgroundDimmerMainView setHidden:NO];
            
            NSLayoutConstraint* newBottomConstraint = [NSLayoutConstraint constraintWithItem:self.socialMediaContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0];
            
            NSLayoutConstraint* newTopConstraint = [NSLayoutConstraint constraintWithItem:self.socialMediaContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:100];
            
            self.adjustedTopConstraint = newTopConstraint;
            
            self.adjustedBottomConstraint = newBottomConstraint;
            
            [self.view layoutIfNeeded];
            
            [self.view removeConstraint:self.SMContainerTopConstraint];
            
            [self.view removeConstraint:self.SMContainerBtmConstraint];
            
            [self.view addConstraint:self.adjustedTopConstraint];
            
            [self.view addConstraint:self.adjustedBottomConstraint];
            
            [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionTransitionNone animations:^{
                /*
                if (darkenBackground) {
                    
                    [self.view insertSubview:backgroundDimmerMainView belowSubview:self.socialMediaContainer];
                    
                    [backgroundDimmerMainView setOpaque:YES];
                    
                    backgroundDimmerMainView.alpha = 0.8;
                }
                */
                [self.view layoutIfNeeded];
                
                [UIView commitAnimations];
                
            } completion:^(BOOL finished) {
                
                isSocialMediaViewInView = YES;
                
            }];
        });
        
    }
}

-(void) dragSocialMediaViewDown
{
    if (isSocialMediaViewInView == YES) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.view layoutIfNeeded];
            
            [self.view removeConstraint:self.adjustedTopConstraint];
            
            [self.view removeConstraint:self.adjustedBottomConstraint];
            
            [self.view addConstraint:self.SMContainerTopConstraint];
            
            [self.view addConstraint:self.SMContainerBtmConstraint];
            
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionNone animations:^{
                
                [self.view layoutIfNeeded];
                
                [backgroundDimmerMainView setOpaque:NO];
                
                backgroundDimmerMainView.alpha = 0.0;
                
                [UIView commitAnimations];
                
            } completion:^(BOOL finished) {
                
                isSocialMediaViewInView = NO;
                
                [self.view sendSubviewToBack:backgroundDimmerMainView];
                
                [backgroundDimmerMainView setHidden:YES];
                
            }];
        });
        
    }
}
 
-(void)constructTwitterView
{
    self.twitterViewController = [[TwitterViewController alloc] init];
    
    NSLog(@"%@", self.twitterViewController.view);
    
    (self.twitterViewController).currentDeal = self.dealSelected;
    
    (self.twitterViewController).delegate = self;
    
    (self.twitterViewController).twitterDelegate = self;
    
    [self.twitterViewController setPageIndex:0];
    
    //[self.SMPageViewController.view addSubview:self.twitterViewController.view];
}

-(void)constructFacebookView
{
    self.fbViewController = [[PSFacebookViewController alloc] init];
    
    (self.fbViewController).delegate = self;

    [self.fbViewController setPageIndex:1];
    
    //[self.SMPageViewController.view addSubview:self.fbViewController.view];
}

-(void)constructInstagramView
{
    self.instaViewController = [[PSInstagramViewController alloc] init];
    
    (self.instaViewController).delegate = self;
    
    [self.instaViewController setPageIndex:2];
}

#pragma mark -
#pragma mark - Background Dimmer Methods
/*
-(void) addBackgroundDimmerViewToMainView
{
    if (!backgroundDimmerMainView) {
        
        UIView* bgDimmer = [[UIView alloc] initWithFrame:self.view.bounds];
        UIColor* dimmerColor = [UIColor blackColor];
        bgDimmer.backgroundColor = dimmerColor;
        [bgDimmer setOpaque:NO];
        bgDimmer.alpha = 0.0;
        [bgDimmer setHidden:YES];
        
        backgroundDimmerMainView = bgDimmer;
        
        //[self.view insertSubview:backgroundDimmerMainView belowSubview:self.socialMediaContainer];
    }
}
*/

-(void) toggleBackgroundDimmerForMainView
{
    if (backgroundDimmerMainView.hidden) {
        [backgroundDimmerMainView setHidden:NO];
        isSocialMediaViewInView = YES;
    }
    else
    {
        [backgroundDimmerMainView setHidden:YES];
        isSocialMediaViewInView = NO;
    }
}

#pragma mark -
#pragma mark - Page View Controller
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    SocialMediaViewController* view = (SocialMediaViewController*) viewController;
    
    NSUInteger index = [view getPageIndex];
    
    if (index == 2) {
        return [self viewControllerAtIndex:0];
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    SocialMediaViewController* view = (SocialMediaViewController*) viewController;
    
    NSUInteger index = [view getPageIndex];
    
    if (index == 0) {
        return [self viewControllerAtIndex:LAST_INDEX];
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (index == 0) {
        return self.twitterViewController;
    }
    else if (index == 1)
    {
        if (!self.fbViewController) {
            [self constructFacebookView];
        }
        
        return self.fbViewController;
    }
    else if (index == 2)
    {
        if (!self.instaViewController) {
            [self constructInstagramView];
        }
        
        return self.instaViewController;
    }
    else return nil;
}

#pragma mark -
#pragma mark - Page View Controller Delegate
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    // The number of items reflected in the page indicator
    
    return 3;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    // the selected item relflected in the page indicator
    return 0;
}


#pragma mark -
#pragma mark - Social Media View Controller Delegate
-(void)viewAppeared:(UIViewController *)presentViewController
{
    
    if ([presentViewController isKindOfClass:[TwitterViewController class]]) {
        
        (self.socialMediaNavBar).barTintColor = [UIColor colorWithRed:0.00 green:0.67 blue:0.93 alpha:1.0];

    }
    else if ([presentViewController isKindOfClass:[PSFacebookViewController class]])
    {
        
        (self.socialMediaNavBar).barTintColor = [UIColor colorWithRed:0.23 green:0.35 blue:0.60 alpha:1.0];
    }
    else if ([presentViewController isKindOfClass:[PSInstagramViewController class]])
    {

        
        (self.socialMediaNavBar).barTintColor = [UIColor colorWithRed:0.74 green:0.16 blue:0.55 alpha:1.0];
    }
    else
    {
        (self.socialMediaNavBar).barTintColor = [UIColor whiteColor];
    }
}


#pragma mark -
#pragma mark - Twitter View Methods
-(void)webViewWithContentView:(CGSize)contentArea
{
    
}


#pragma mark -
#pragma mark - Navigation Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

-(void) cancelButton_pressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:UNWIND_TO_ALL_CURRENT_DEALS sender:self];
    
}


#pragma mark -
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
