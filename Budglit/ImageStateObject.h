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
    BOOL hasImage;
    BOOL queuedOp;
    BOOL imageCached;
}

@property (nonatomic, strong) NSString* imagePath;

@property (nonatomic, strong) NSURLRequest* request;

@property (nonatomic, strong) NSHTTPURLResponse* response;

-(instancetype)init;

-(void)recordImageHTTPResponse:(NSHTTPURLResponse*)response andRequest:(NSURLRequest*)request hasImage:(BOOL)exist;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL imageExists;

@end
