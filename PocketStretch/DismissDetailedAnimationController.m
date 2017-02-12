//
//  DismissDetailedAnimationController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 2/10/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DismissDetailedAnimationController.h"
#import "PSAllDealsTableViewController.h"
#import "PSDealDetailViewController.h"

@implementation DismissDetailedAnimationController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    PSDealDetailViewController* fromViewController = (PSDealDetailViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PSAllDealsTableViewController* toViewController = (PSAllDealsTableViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
}

@end
