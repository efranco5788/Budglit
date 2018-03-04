//
//  DismissDetailedAnimationController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 2/10/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSAllDealsTableViewController;
@class DealDetailViewController;

@interface DismissDetailedAnimationController : NSObject<UIViewControllerAnimatedTransitioning>

-(void)setDestinationFrame:(CGRect)frame;

-(CGRect)getDestinationFrame;

@end
