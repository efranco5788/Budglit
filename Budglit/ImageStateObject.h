//
//  ImageStateObject.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/27/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStateObject : NSObject
{
    BOOL queuedOp;
    BOOL imageCached;
}

@property (nonatomic, strong) NSString* imagePath;
@property (nonatomic, strong) NSURLRequest* request;
@property (nonatomic, strong) NSHTTPURLResponse* response;
@property (nonatomic, assign) BOOL hasImage;

-(instancetype)init;

-(instancetype)initWithURL:(NSString*)urlString;

-(void)recordImageHTTPResponse:(NSHTTPURLResponse*)response andRequest:(NSURLRequest*)request hasImage:(BOOL)exist;

@end
