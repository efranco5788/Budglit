//
//  DealDetailedAnimationController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 2/8/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealDetailedAnimationController.h"
#import "DealDetailViewController.h"
#import "AppDelegate.h"

@implementation DealDetailedAnimationController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    // All Deals Table View Controller
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // Details View Controller
    DealDetailViewController* toViewController = (DealDetailViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView = [transitionContext containerView];
    
    [containerView setBackgroundColor:[UIColor whiteColor]];
    
    CGRect barFrame = fromViewController.navigationController.navigationBar.frame;
    CGRect containerBounds = [containerView bounds];
    CGRect newInsetFrame = CGRectInset(containerBounds, barFrame.origin.x, barFrame.origin.y);
    CGRect newFrame = CGRectOffset(newInsetFrame, barFrame.origin.x, barFrame.origin.y);
    
    [toViewController.view setClipsToBounds:YES];
    
    CGRect startFrame = [toViewController getOriginalPosition];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:toViewController];
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    UIColor* barColor = [appDelegate getPrimaryColor];
    
    [navController.navigationBar setBarTintColor:barColor];
    
    [navController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [navController.navigationBar setTranslucent:YES];
    
    [navController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [containerView addSubview:fromViewController.view];
    
    [containerView addSubview:navController.view];
    
    [toViewController.view setFrame:startFrame];
    
    //toViewController.view.layer.transform = [self animationHelper:(M_PI / 2)];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        fromViewController.view.layer.opacity = 0;
        
        [toViewController.view setFrame:newFrame];

    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        [containerView addSubview:navController.view];
        
    }];
    
    
}


@end
