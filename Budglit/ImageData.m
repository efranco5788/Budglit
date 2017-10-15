//
//  ImageData.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/24/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "ImageData.h"

#define imageDataKey @"imageData"

@implementation ImageData

-(instancetype)initWithImage:(UIImage*)image
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.image forKey:imageDataKey];
}

-(instancetype)initWithCoder:(NSCoder *)decoder
{
    UIImage* decodedImage = [decoder decodeObjectForKey:imageDataKey];
    
    return [self initWithImage:decodedImage];
}

@end
