//
//  SocialMediaFeed.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/12/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialMediaFeed : NSObject

@property (strong, nonatomic) NSArray* list;

-(instancetype)init;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger totalCount;

@property (NS_NONATOMIC_IOSONLY, getter=getCurrentList, readonly, copy) NSArray *currentList;

-(void)addListObject:(NSData*)object;

@end
