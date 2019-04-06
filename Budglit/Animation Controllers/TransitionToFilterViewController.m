//
//  TransitionToFilterViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 4/4/19.
//  Copyright © 2019 Emmanuel Franco. All rights reserved.
//

#import "TransitionToFilterViewController.h"

@implementation TransitionToFilterViewController

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    // All Deals Table View Controller
    UIViewController* from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // Filter View Controller
    UIViewController* to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* container = [transitionContext containerView];
    
    UIView* snapshot = [from.view snapshotViewAfterScreenUpdates:NO];
    
    [container addSubview:snapshot];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
        [container addSubview:to.view];
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
