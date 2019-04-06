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
    self = [self initWithURL:nil];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithURL:(NSString *)urlString
{
    self = [super init];
    
    if(!self) return nil;
    
    if(!urlString) self.imagePath = nil;
    else self.imagePath = urlString;
    
    self.request = nil;
    self.response = nil;
    [self setHasImage:NO];
    queuedOp = NO;
    imageCached = NO;
    
    return self;
}

-(void)recordImageHTTPResponse:(NSHTTPURLResponse *)response andRequest:(NSURLRequest *)request hasImage:(BOOL)exist
{
    [self setHasImage:exist];
    imageCached = YES;
    self.request = request;
    self.response = response;
    NSLog(@"Image Response Recorded");
    
}

@end
