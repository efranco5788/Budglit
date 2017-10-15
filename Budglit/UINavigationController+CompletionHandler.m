//
//  UINavigationController+CompletionHandler.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/28/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "UINavigationController+CompletionHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (CompletionHandler)

-(void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController *)navController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [navController pushViewController:viewController animated:animated];
        [CATransaction commit];
    }
    else{
        [navController pushViewController:viewController animated:NO];
        completion();
    }
}

-(void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController *)navController withTransition:(UIModalTransitionStyle*)transitionStyle animated:(BOOL)animated completion:(void (^)(void))completion
{
    navController.transitioningDelegate = self;
    
    navController.modalTransitionStyle = *transitionStyle;
    
    [self completionhandler_pushViewController:viewController withController:navController animated:animated completion:completion];
}

-(void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController *)navController shouldHideNavigationBar:(BOOL)hide withTransition:(UIModalTransitionStyle *)transitionStyle animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (hide) {
        [navController setNavigationBarHidden:YES];
    }
    
    [self completionhandler_pushViewController:viewController withController:navController withTransition:transitionStyle animated:animated completion:completion];
}

-(void)completionhandler_popViewControllerAnimated:(BOOL)animated navigationController:(UINavigationController *)navController completion:(void (^)(void))completion
{
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [navController popViewControllerAnimated:animated];
        [CATransaction commit];
    }
    else{
        [navController popViewControllerAnimated:NO];
        completion();
    }
}

-(void)completionhandler_popToViewController:(UIViewController *)toViewController withController:(UINavigationController *)navController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [navController popToViewController:toViewController animated:animated];
        [CATransaction commit];
    }
    else{
        [navController popToViewController:toViewController animated:NO];
        completion();
    }
}

-(void)completionhandler_popViewController:(UIViewController *)viewController withController:(UINavigationController *)navController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [navController popViewControllerAnimated:animated];
        [CATransaction commit];
    }
    else{
        [navController popViewControllerAnimated:NO];
        completion();
    }
}

@end
