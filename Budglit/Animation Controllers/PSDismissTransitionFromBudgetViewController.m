//
//  PSDismissTransitionFromBudgetViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "PSDismissTransitionFromBudgetViewController.h"
#import "LoadingLocalDealsViewController.h"
#import "FilterViewController.h"


@implementation PSDismissTransitionFromBudgetViewController

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    FilterViewController* fromViewController = (FilterViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = fromViewController.view.frame;
    
    CGFloat finalYPosition = -finalFrame.size.height;
    
    finalFrame.origin.y = finalYPosition;
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.5 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionNone animations:^{
        
        fromViewController.view.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        [fromViewController.view removeFromSuperview];
        
    }];
    
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

@end
