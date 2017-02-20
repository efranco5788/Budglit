//
//  NSString+Encode.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/8/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

+ (NSString*)hash:(NSString *)data secret:(NSString *)key;

- (NSString*) encodeString:(NSStringEncoding) encoding;

@end
