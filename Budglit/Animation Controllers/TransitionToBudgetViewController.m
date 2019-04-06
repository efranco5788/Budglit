//
//  TransitionToBudgetViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "TransitionToBudgetViewController.h"
#import "math.h"

#define PS_WHOLE_PERCENTAGE 100;
#define PS_DESIRED_PERCENTAGE_FOR_X 0;
#define PS_DESIRED_PERCENTAGE_FOR_Y 25;
#define PS_DESIRED_PERCENTAGE_FOR_WIDTH 100;
#define PS_DESIRED_PERCENTAGE_FOR_HEIGHT 55;

@implementation TransitionToBudgetViewController

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    // Loading Local Deals View Controller
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // Filter View Controller
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    CGRect mainFrame = [[UIScreen mainScreen] bounds];
    
    CGFloat mainFrameHeight = mainFrame.size.height;
    CGFloat mainFrameWidth = mainFrame.size.width;
    
    CGFloat numberForDesiredPercentageY = mainFrameHeight * PS_DESIRED_PERCENTAGE_FOR_Y;
    CGFloat numberForDesiredPercentageX = mainFrameWidth * PS_DESIRED_PERCENTAGE_FOR_X;
    CGFloat numberForDesiredPercentageHeight = mainFrameHeight * PS_DESIRED_PERCENTAGE_FOR_HEIGHT;
    CGFloat numberForDesiredPercentageWidth = mainFrameWidth * PS_DESIRED_PERCENTAGE_FOR_WIDTH;
    
    CGFloat percentageConvertedY = numberForDesiredPercentageY / PS_WHOLE_PERCENTAGE;
    CGFloat percentageConvertedX = numberForDesiredPercentageX / PS_WHOLE_PERCENTAGE;
    CGFloat percentageConvertedHeight = numberForDesiredPercentageHeight / PS_WHOLE_PERCENTAGE;
    CGFloat percentageConvertedWidth = numberForDesiredPercentageWidth / PS_WHOLE_PERCENTAGE;
    
    CGFloat newDesiredY = rintf(percentageConvertedY);
    CGFloat newDesiredX = rintf(percentageConvertedX);
    CGFloat newDesiredHeight = rintf(percentageConvertedHeight);
    CGFloat newDesiredWidth = rintf(percentageConvertedWidth);
    
    CGRect finalFrame = CGRectMake(newDesiredX, newDesiredY, newDesiredWidth, newDesiredHeight);
    

    toViewController.view.frame = finalFrame;
    
    toViewController.view.alpha = 1.0;
    
    fromViewController.view.alpha = 1.0;
    
    fromViewController.view.frame = mainFrame;
    
    
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        toViewController.view.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        [containerView addSubview:fromViewController.view];
        
        [containerView addSubview:toViewController.view];
        
    }];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

@end
