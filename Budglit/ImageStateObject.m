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
    
    if(!self) return nil;
    
    self.imagePath = nil;
    self.request = nil;
    self.response = nil;
    [self setHasImage:NO];
    queuedOp = NO;
    imageCached = NO;
    
    return self;
}

-(void)recordImageHTTPResponse:(NSHTTPURLResponse *)response andRequest:(NSURLRequest *)request hasImage:(BOOL)exist
{
    NSLog(@"%@", self.request);
    [self setHasImage:exist];
    imageCached = YES;
    self.request = request;
    self.response = response;
    
    
}

@end
