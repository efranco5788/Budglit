//
//  UIImage+Resizing.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "UIImage+Resizing.h"

@implementation UIImage (Resizing)

-(UIImage*) resizeImageToHeight:(NSUInteger)height andWidth:(NSUInteger)width
{
    if (self.size.height < height) {
        return nil;
    }
    
    if (self.size.width < width) {
        return nil;
    }
    
    float actualHeight = self.size.height;
    float actualWidth = self.size.width;
    float imgRatio = self.size.width/self.size.height;
    float maxRatio = width/height;
    float compressionQuality = 0.5;//50 percent compression
    
    if (imgRatio < maxRatio) {
        //adjust width according to maxHeight
        imgRatio = height / actualHeight;
        actualWidth = imgRatio * actualWidth;
        actualHeight = height;
    }
    else if(imgRatio > maxRatio)
    {
        //adjust height according to maxWidth
        imgRatio = width / actualWidth;
        actualHeight = imgRatio * actualHeight;
        actualWidth = width;
    }
    else
    {
        actualHeight = height;
        actualWidth = width;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}


-(NSData *)resizeImageDataToHeight:(NSUInteger)height andWidth:(NSUInteger)width
{
    if (self.size.height <= height) {
        return nil;
    }
    
    if (self.size.width <= width) {
        return nil;
    }
    
    float actualHeight = self.size.height;
    float actualWidth = self.size.width;
    float imgRatio = self.size.width/self.size.height;
    float maxRatio = width/height;
    float compressionQuality = 0.5;//50 percent compression
    
    if (imgRatio < maxRatio) {
        //adjust width according to maxHeight
        imgRatio = height / actualHeight;
        actualWidth = imgRatio * actualWidth;
        actualHeight = height;
    }
    else if(imgRatio > maxRatio)
    {
        //adjust height according to maxWidth
        imgRatio = width / actualWidth;
        actualHeight = imgRatio * actualHeight;
        actualWidth = width;
    }
    else
    {
        actualHeight = height;
        actualWidth = width;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}


@end
