//
//  DealDetailedAnimationController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 2/8/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DealDetailedAnimationController.h"
#import "PSAllDealsTableViewController.h"
#import "PSDealDetailViewController.h"

@implementation DealDetailedAnimationController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    PSAllDealsTableViewController* fromViewController = (PSAllDealsTableViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PSDealDetailViewController* toViewController = (PSDealDetailViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView = [transitionContext containerView];
    
    [containerView setBackgroundColor:[UIColor whiteColor]];
    
    CGRect barFrame = fromViewController.navigationController.navigationBar.frame;
    CGRect containerBounds = [containerView bounds];
    CGRect newInsetFrame = CGRectInset(containerBounds, barFrame.origin.x, barFrame.origin.y);
    CGRect newFrame = CGRectOffset(newInsetFrame, barFrame.origin.x, barFrame.origin.y);
    
    [toViewController.view setClipsToBounds:YES];
    
    CGRect startFrame = [toViewController getOriginalPosition];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:toViewController];
    
    [containerView addSubview:fromViewController.view];
    
    [containerView addSubview:navController.view];
    
    [toViewController.view setFrame:startFrame];
    
    [UIView animateWithDuration:0.7 animations:^{
        
        fromViewController.view.layer.opacity = 0;
        
        [toViewController.view setFrame:newFrame];

    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        [containerView addSubview:navController.view];
        
    }];
    
    
}

@end
