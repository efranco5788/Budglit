//
//  AnimationHelper.h
//  Budglit
//
//  Created by Emmanuel Franco on 12/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationHelper : NSObject

-(CATransform3D)rotateAngle:(double)angle;

-(void)perspectiveTransform:(UIView*)forView;

@end
