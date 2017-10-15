//
//  InstagramFeed.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/12/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "SocialMediaFeed.h"

@class InstagramObject;

@interface InstagramFeed : SocialMediaFeed

-(instancetype)init;

-(void)addObjectToFeed:(InstagramObject*)object;

@end
