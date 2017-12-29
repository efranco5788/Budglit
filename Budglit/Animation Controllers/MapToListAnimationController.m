//
//  MapToListAnimationController.m
//  Budglit
//
//  Created by Emmanuel Franco on 12/15/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "MapToListAnimationController.h"
#import "MapViewController.h"
#import "PSAllDealsTableViewController.h"

@implementation MapToListAnimationController

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    MapViewController* from = (MapViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PSAllDealsTableViewController* to = (PSAllDealsTableViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView = [transitionContext containerView];
    
    [to.view setClipsToBounds:YES];
    
    [to.view setHidden:YES];
    [from.navigationController.navigationBar setHidden:YES];

    [containerView addSubview:to.view];
    
    AnimationHelper* animationHelper = [[AnimationHelper alloc] init];
    
    [animationHelper perspectiveTransform:containerView];
    to.view.layer.transform = [animationHelper rotateAngle:M_PI / 2];
    to.navigationController.navigationBar.layer.transform = [animationHelper rotateAngle:M_PI / 2];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/3.0 animations:^{
            from.view.layer.transform = [animationHelper rotateAngle:(-M_PI) / 2];
            [from.view layoutIfNeeded];

        }];

        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/3.0 animations:^{
            [to.view.layer setHidden:NO];
            to.view.layer.transform = [animationHelper rotateAngle:0.0];
            to.navigationController.navigationBar.layer.transform = [animationHelper rotateAngle:0.0];
            //to.navigationController.view.layer.transform = [animationHelper rotateAngle:0.0];
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations:^{
            CGRect navBar = to.navigationController.navigationBar.frame;
            //to.view.frame = CGRectMake(0, navBar.size.height, containerView.frame.size.width, containerView.frame.size.height);
            //to.view.frame = containerView.frame;
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }];
        
    } completion:^(BOOL finished) {
        if (finished) {
            [to.navigationController.navigationBar setHidden:NO];
            from.view.layer.transform = CATransform3DIdentity;
            [transitionContext completeTransition:YES];
            [containerView layoutIfNeeded];
            [to.view layoutIfNeeded];
        }
        
    }];
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.9f;
}

@end
