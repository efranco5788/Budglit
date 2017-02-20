//
//  ImageStateObject.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "ImageStateObject.h"

@implementation ImageStateObject

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.imagePath = nil;
        self.request = nil;
        self.response = nil;
        hasImage = NO;
        queuedOp = NO;
        imageCached = NO;
    }
    
    return self;
}

-(void)recordImageHTTPResponse:(NSHTTPURLResponse *)response andRequest:(NSURLRequest *)request hasImage:(BOOL)exist
{
    if (exist) hasImage = YES;
    else hasImage = NO;
    
    imageCached = YES;
    self.request = request;
    self.response = response;
}

-(BOOL)imageExists
{
    return hasImage;
}

@end