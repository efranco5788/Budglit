//
//  DismissDetailedAnimationController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 2/10/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DismissDetailedAnimationController.h"
#import "PSAllDealsTableViewController.h"
#import "DealDetailViewController.h"

@implementation DismissDetailedAnimationController
{
    CGRect desinationFrame;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    DealDetailViewController* fromViewController = (DealDetailViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PSAllDealsTableViewController* toViewController = (PSAllDealsTableViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView = [transitionContext containerView];
    
    [containerView setBackgroundColor:[UIColor whiteColor]];
    
    [toViewController.view setClipsToBounds:YES];
    
    [containerView addSubview:toViewController.view];
    
    CGRect newFrame = CGRectOffset(fromViewController.view.frame, 0, fromViewController.view.frame.size.height);
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [fromViewController.view setFrame:newFrame];
        
        fromViewController.view.layer.opacity = 0;
        
        toViewController.view.layer.opacity = 1;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];

}

-(void)setDestinationFrame:(CGRect)frame
{
    desinationFrame = frame;
}

-(CGRect)getDestinationFrame
{
    return desinationFrame;
}

@end
