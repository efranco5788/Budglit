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

    [containerView addSubview:to.view];
    
    [to.view setHidden:YES];
    
    AnimationHelper* animationHelper = [[AnimationHelper alloc] init];
    
    [animationHelper perspectiveTransform:containerView];
    to.view.layer.transform = [animationHelper rotateAngle:M_PI / 2];
    to.navigationController.navigationBar.layer.transform = [animationHelper rotateAngle:M_PI / 2];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/3.0 animations:^{
            [from.navigationController.navigationBar setHidden:YES];
            from.view.layer.transform = [animationHelper rotateAngle:(-M_PI) / 2];
            
            [from.view layoutIfNeeded];
        }];

        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/3.0 animations:^{
            [to.view.layer setHidden:NO];
            to.view.layer.transform = [animationHelper rotateAngle:0.0];
            to.navigationController.navigationBar.layer.transform = [animationHelper rotateAngle:0.0];
            
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:3/3.0 relativeDuration:1/3.0 animations:^{
            CGRect barFrame = from.navigationController.navigationBar.frame;
            CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
            CGRect containerBounds = [containerView bounds];
            CGFloat newOriginY = barFrame.size.height + statusBar.size.height;
            CGRect finalFrame = CGRectOffset(containerBounds, 0, newOriginY);
            [to.view setFrame:finalFrame];
            [to.navigationController.navigationBar setHidden:NO];
            
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }];
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            from.view.layer.transform = CATransform3DIdentity;
            [transitionContext completeTransition:YES];
            
            [containerView layoutIfNeeded];
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }
        
    }];
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.9f;
}

@end
