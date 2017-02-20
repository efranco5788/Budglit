//
//  UINavigationController+CompletionHandler.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/28/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (CompletionHandler) <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

- (void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController*) navController
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion;

- (void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController*) navController withTransition:(UIModalTransitionStyle*) transitionStyle
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion;

- (void)completionhandler_pushViewController:(UIViewController *)viewController withController:(UINavigationController*) navController shouldHideNavigationBar:(BOOL) hide withTransition:(UIModalTransitionStyle*) transitionStyle
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion;

- (void)completionhandler_popViewControllerAnimated:(BOOL)animated navigationController:(UINavigationController*)navController completion:(void (^)(void))completion;

- (void)completionhandler_popViewController:(UIViewController *)viewController withController:(UINavigationController*) navController
                                   animated:(BOOL)animated
                                 completion:(void (^)(void))completion;

- (void)completionhandler_popToViewController:(UIViewController *)toViewController withController:(UINavigationController*) navController
                                     animated:(BOOL)animated
                                   completion:(void (^)(void))completion;

@end
