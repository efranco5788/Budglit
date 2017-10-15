//
//  SocialMediaFeed.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/12/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "SocialMediaFeed.h"

@interface SocialMediaFeed()

@end

@implementation SocialMediaFeed

-(instancetype)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.list = [[NSArray alloc] init];
    
    return self;
}

-(NSUInteger)totalCount
{
    if (self.list.count < 1) {
        return 0;
    }
    else return self.list.count;
}

-(void)addListObject:(NSData*)object
{
    
}

-(NSArray *)getCurrentList
{
    if (self.list.count < 1) {
        return nil;
    }
    else{
        return self.list.copy;
    }
}

@end
