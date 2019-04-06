//
//  ImageDataCache.m
//  Budglit
//
//  Created by Emmanuel Franco on 1/19/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "ImageDataCache.h"

@implementation ImageDataCache

static ImageDataCache* sharedImageDataCache;

+(id)sharedImageDataCache
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedImageDataCache = [[self alloc] init];
        
    });
    
    return sharedImageDataCache;
}

-(instancetype)init
{
    self = [super init];
    
    if(!self) return nil;
    
    return self;
}

-(void)setObject:(id)obj forKey:(id)key
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [super setObject:obj forKey:key];
        
    });
}

-(void)saveFileToPersistentStorageCache:(id)data withKey:(NSString *)key addCompletion:(generalBlockResponse)completionHandler
{
    if(!data){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionHandler(NO);
            
        });
        
    }
    else{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString* cacheDirectory = [paths objectAtIndex:0];
            
            NSString* imgPath = [cacheDirectory stringByAppendingPathComponent:key];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
                
                NSDictionary* attributes = [NSDictionary dictionaryWithObject:@"NSFileCreationDate" forKey:@"NSFileAttributeKey"];
                
                BOOL created = [[NSFileManager defaultManager] createFileAtPath:imgPath contents:data attributes:attributes];
                
                NSArray* items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil];
                
                NSLog(@"Directory: %@", items);
                
                completionHandler(created);
                
            }
            else{
                
                NSLog(@"File Exists");
                completionHandler(YES);

            }
            
        });
        
        
    }
    
}

-(void)getFileFromPersistentStorageCache:(NSString *)fileName addCompletion:(imageResponse)completionHandler
{
    if(!fileName){
        
        completionHandler(nil);
        
    }
    else{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString* cacheDirectory = [paths objectAtIndex:0];
            
            NSArray* pathComponents = [fileName componentsSeparatedByString:@"/"];
            
            if (!pathComponents || pathComponents.count < 1) completionHandler(nil);
            else{
                
                NSString* imgName = pathComponents.lastObject;
                
                NSString* filePath = [cacheDirectory stringByAppendingPathComponent:imgName];
                
                NSData* imgData = [NSData dataWithContentsOfFile:filePath];
                
                UIImage* img = [UIImage imageWithData:imgData scale:UIScreen.mainScreen.scale];
                
                if(!img) completionHandler(nil);
                else completionHandler(img);
                
                
            }
            
            
        });
        
        
    }
    
}

@end
