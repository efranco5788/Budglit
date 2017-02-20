//
//  UIImage+Resizing.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resizing)

-(UIImage*) resizeImageToHeight:(NSUInteger)height andWidth:(NSUInteger)width;

-(NSData*) resizeImageDataToHeight:(NSUInteger)height andWidth:(NSUInteger)width;

@end
