//
//  InstagramObject.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/17/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramObject.h"
#import "ImageStateObject.h"

#define INSTAGRAM_COUNT @"count"
#define INSTAGRAM_LOW_RESOLUTION @"low_resolution"
#define INSTAGRAM_STANDARD_RESOLUTION @"standard_resolution"
#define INSTAGRAM_THUMBNAIL @"thumbnail"
#define INSTAGRAM_LOCATION_ID @"id"

//CGFloat height;

@implementation InstagramObject


-(id)init
{
    self = [super init];
    
    if (!self) return nil;
    
    self.instagramID = [[NSString alloc] init];
    self.attribution = [[NSString alloc] init];
    self.caption = [[NSString alloc] init];
    self.timeCreatedString = [[NSString alloc] init];
    self.type = [[NSString alloc] init];
    self.link = [[NSURL alloc] init];
    self.likesString = [[NSString alloc] init];
    self.comments = [[NSDictionary alloc] init];
    self.images = [[NSDictionary alloc] init];
    self.videos = [[NSDictionary alloc] init];
    self.location = [[NSDictionary alloc] init];
    self.tags = [[NSDictionary alloc] init];
    self.mediaStateHandler = [[ImageStateObject alloc] init];
    return self;
}

-(id)initWithInstagrameID:(NSString*)idInt andAttribution:(NSString *)attri andCaption:(NSString *)cap andTimestamp:(NSInteger)timestamp andType:(NSString *)aType andInstagramLink:(NSString *)linkString andCommnents:(NSDictionary *)instaComments andImages:(NSDictionary *)imgs andVideos:(NSDictionary *)vids andLocation:(NSDictionary *)instaLocation andTags:(NSDictionary *)instaTags
{
    self = [super init];
    
    if (!self) return nil;
    
    if (idInt) {
        self.instagramID = [NSString stringWithString:idInt];
    }
    
    if (timestamp) {
        self.timeCreatedString = [NSString stringWithFormat:@"%li", (long)timestamp];
    }
    
    self.attribution = [NSString stringWithString:attri];
    
    self.caption = [NSString stringWithString:cap];
    
    self.type = [NSString stringWithString:aType];
    
    self.link = [NSURL URLWithString:linkString];
    
    self.comments = instaComments.copy;
    
    self.images = imgs.copy;
    
    self.videos = vids.copy;
    
    self.location = instaLocation.copy;
    
    self.tags = instaTags.copy;
    
    self.objHeight = [[NSNumber alloc] init];
    
    return self;
    
}

-(void)setHeight:(CGFloat)aHeight
{
    self.objHeight = [[NSNumber alloc] initWithFloat:aHeight];
    
}

-(CGFloat)getHeight
{
    CGFloat height = [self.objHeight floatValue];
    
    NSLog(@"Height is %f", height);
    
    return height;
}

-(CGRect)getMediaFrame
{
    CGFloat width;
    CGFloat height;
    CGRect frame;
    
    if (self.images) {
        width = [[self.images valueForKey:@"width"] floatValue];
        height = [[self.images valueForKey:@"height"] floatValue];
    }
    else if (self.videos)
    {
        width = [[self.videos valueForKey:@"width"] floatValue];
        height = [[self.videos valueForKey:@"height"] floatValue];
    }
    else return CGRectNull;
    
    frame = CGRectMake(0, 0, width, height);
    
    return frame;
}

-(void)toggleMuteButton
{
    if ([self.avPlayer isMuted]) self.avPlayer.muted = NO;
    else self.avPlayer.muted = YES;
}

@end
