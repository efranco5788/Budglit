//
//  InstagramFeed.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/12/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramFeed.h"
#import "InstagramObject.h"

@implementation InstagramFeed

-(id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(void)addObjectToFeed:(InstagramObject*)object
{
    NSMutableArray* tmpFeedList = [self.list mutableCopy];
    
    [tmpFeedList addObject:object];
    
    self.list = tmpFeedList.copy;
}

@end
