//
//  ImageDataCache.m
//  Budglit
//
//  Created by Emmanuel Franco on 1/19/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "ImageDataCache.h"

@implementation ImageDataCache

-(instancetype)init
{
    self = [super init];
    
    if(!self) return nil;
    
    return self;
}

-(void)saveFileToPersistentStorageCache:(id)data withKey:(NSString *)key addCompletion:(generalBlockResponse)completionHandler
{
    if(!data)completionHandler(NO);
    else{
        
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
            NSLog(@"File Already Exists");
            completionHandler(YES);
        }
        
        
    }
    
}

-(void)getFileFromPersistentStorageCache:(NSString *)fileName addCompletion:(blockResponse)completionHandler
{
    if(!fileName) completionHandler(nil);
    else{
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString* cacheDirectory = [paths objectAtIndex:0];
        
        NSArray* pathComponents = [fileName componentsSeparatedByString:@"/"];
        
        if (!pathComponents || pathComponents.count < 1) completionHandler(nil);
        else{
            
            NSString* imgName = pathComponents.lastObject;
            
            NSString* filePath = [cacheDirectory stringByAppendingPathComponent:imgName];
            
            NSData* data = [[NSFileManager defaultManager] contentsAtPath:filePath];
            
            if(!data) completionHandler(nil);
            else completionHandler(data);
            
        }
    }
    
}

@end
