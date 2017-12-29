//
//  DismissMapToListAnimationController.m
//  Budglit
//
//  Created by Emmanuel Franco on 12/20/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DismissMapToListAnimationController.h"
#import "MapViewController.h"
#import "PSAllDealsTableViewController.h"
#import "AnimationHelper.h"

@implementation DismissMapToListAnimationController

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    MapViewController* to = (MapViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PSAllDealsTableViewController* from = (PSAllDealsTableViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //UIView* containerView = [transitionContext containerView];
    
    [to.view setClipsToBounds:YES];
    
    [to.view setHidden:YES];
    
    //[containerView addSubview:to.view];
    
    AnimationHelper* animationHelper = [[AnimationHelper alloc] init];
    
    [animationHelper perspectiveTransform:to.view];
    
    to.view.layer.transform = [animationHelper rotateAngle:M_PI / 2];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/3.0 animations:^{
            from.view.layer.transform = [animationHelper rotateAngle:(-M_PI) / 2];
            [from.view layoutIfNeeded];
            
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/3.0 animations:^{
            [to.view.layer setHidden:NO];
            to.view.layer.transform = [animationHelper rotateAngle:0.0];
            [to.view layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations:^{
            [to.view layoutIfNeeded];
            [to.navigationController.view layoutIfNeeded];
        }];
        
    } completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:YES];
            from.view.layer.transform = CATransform3DIdentity;
            [from.view removeFromSuperview];
            [to.view layoutIfNeeded];
        }
        
    }];
    
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.9f;
}

@end
