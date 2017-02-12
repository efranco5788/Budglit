//
//  ImageDataDoc.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/25/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "ImageDataDoc.h"

#define defaultImageDocPathKey @"images"

static ImageDataDoc* sharedManager;

@interface ImageDataDoc ()

@end

@implementation ImageDataDoc

+(ImageDataDoc*)sharedBudgetManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    
    return sharedManager;
}


-(id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}


-(id)initDirectory
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    [self createDataPath:IMAGE_DIRECTORY_NAME];
    
    return self;
}

#pragma mark -
#pragma mark - File Methods
-(NSString*)saveData:(NSData*)imageData
{
    NSString* documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString* imageDir = [documentDir stringByAppendingPathComponent:self.dirName];
    
    NSString* identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSString* fileIdentifierPath = [imageDir stringByAppendingPathComponent:identifier];
    
    NSString* filePathWithExtension = [fileIdentifierPath stringByAppendingPathExtension:@"jpeg"];
    
    NSFileManager* fileMngr = [NSFileManager defaultManager];

    if ([fileMngr createFileAtPath:filePathWithExtension contents:imageData attributes:nil]) {
        
        return filePathWithExtension;
        
    }
    
    return nil;
}

-(BOOL)deleteAllData
{
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    
    if (![fileMngr fileExistsAtPath:self.dirName isDirectory:&isDir]) {
        
        return NO;
        
    }
    
    NSDirectoryEnumerator* dirEm = [fileMngr enumeratorAtPath:self.dirName];
    
    NSError* rmError = nil;
    
    BOOL res;
    
    NSString* file;
    
    while (file = [dirEm nextObject]) {
        
        res = [fileMngr removeItemAtPath:file error:&rmError];
        
        if (!res && rmError) {
            NSLog(@"Could not delete the file. %@", rmError);
        }
        
    }
    
    NSLog(@"All files in Image Directory have been cleared");
    
    return YES;
    
}

#pragma mark -
#pragma mark - Modyfing Document Path Methods
-(BOOL)createDataPath:(NSString*) aDirName
{
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    
    NSString* userDocumentsPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString* newDirectoryPath = [userDocumentsPath stringByAppendingPathComponent:aDirName];
    
    NSURL* newDirectoryURL = [NSURL URLWithString:newDirectoryPath];
    
    BOOL isDir;
    
    if ([fileMngr fileExistsAtPath:newDirectoryPath isDirectory:&isDir]) {
        
        [self setDirName:aDirName];
        [self setDocPath:newDirectoryPath];
        [self setDocPathURL:newDirectoryURL];
        
        return NO;
        
    }
    
    NSError* dirError;
    
    if ([fileMngr createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:NO attributes:nil error:&dirError]) {
        
        NSLog(@"New Directory created");
        
        [self setDirName:aDirName];
        [self setDocPath:newDirectoryPath];
        [self setDocPathURL:newDirectoryURL];
        
        return YES;
    }
    else
    {
        NSLog(@"%@", dirError);
        return NO;
    }

}

@end
