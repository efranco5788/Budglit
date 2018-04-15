//
//  ImageDataCache.h
//  Budglit
//
//  Created by Emmanuel Franco on 1/19/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^blockResponse)(id object);
typedef void (^generalBlockResponse)(BOOL success);

@interface ImageDataCache : NSCache

-(void)saveFileToPersistentStorageCache:(id)data withKey:(NSString*)key addCompletion:(generalBlockResponse)completionHandler;

-(void)getFileFromPersistentStorageCache:(NSString*)fileName addCompletion:(blockResponse)completionHandler;

@end
