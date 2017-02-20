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

-(id)init;

-(NSUInteger)totalCount;

-(NSArray*)getCurrentList;

-(void)addListObject:(NSData*)object;

@end
