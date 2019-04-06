//
//  DismissMapToListAnimationController.m
//  Budglit
//
//  Created by Emmanuel Franco on 12/20/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "DismissMapToListAnimationController.h"
#import "AnimationHelper.h"

@implementation DismissMapToListAnimationController

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    // Map View Controller
    UIViewController* from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //All Deals Table View Controller
    UIViewController* to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* snapshot = [from.view snapshotViewAfterScreenUpdates:NO];
    
    UIView* containerView = [transitionContext containerView];
    
    [snapshot setClipsToBounds:YES];
    
    [containerView insertSubview:to.view atIndex:0];
    [containerView addSubview:snapshot];
    
    [from.view setHidden:YES];
    
    AnimationHelper* animationHelper = [[AnimationHelper alloc] init];
    
    [animationHelper perspectiveTransform:containerView];
    
    to.view.layer.transform = [animationHelper rotateAngle:-M_PI / 2];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/3.0 animations:^{
            [snapshot setFrame:containerView.frame];
            [snapshot layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/3.0 animations:^{
            snapshot.layer.transform = [animationHelper rotateAngle:M_PI / 2];
            [snapshot layoutIfNeeded];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations:^{
            to.view.layer.transform = [animationHelper rotateAngle:0.0];
            [to.view layoutIfNeeded];
        }];
        
    } completion:^(BOOL finished) {
        if (finished) {
            from.view.layer.transform = CATransform3DIdentity;
            [from.view setHidden:NO];
            [snapshot removeFromSuperview];
            [to.view layoutIfNeeded];
            
            [transitionContext completeTransition:YES];
        }
        
    }];
    
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.9f;
}

@end
