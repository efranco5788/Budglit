//
//  ImageDataDoc.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/25/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageData.h"

#define IMAGE_DIRECTORY_NAME @"dealImages"

@interface ImageDataDoc : NSObject

+(ImageDataDoc*) sharedBudgetManager;

@property (nonatomic, strong) NSString* dirName;

@property (nonatomic, strong) NSString* docPath;

@property (nonatomic, strong) NSURL* docPathURL;

-(id) init;

-(id) initDirectory;

-(NSString*) saveData:(NSData*)imageData;

-(BOOL) deleteAllData;

@end
