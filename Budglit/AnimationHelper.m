//
//  AnimationHelper.m
//  Budglit
//
//  Created by Emmanuel Franco on 12/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "AnimationHelper.h"

@implementation AnimationHelper

-(CATransform3D)rotateAngle:(double)angle
{
    return CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
}

-(void)perspectiveTransform:(UIView *)forView
{
    CATransform3D t = CATransform3DIdentity;
    
    t.m34 = -0.002;
    
    forView.layer.sublayerTransform = t;
}

@end
