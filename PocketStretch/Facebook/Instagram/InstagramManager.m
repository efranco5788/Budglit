//
//  InstagramManager.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "InstagramManager.h"
#import "InstagramFeed.h"
#import "InstagramObject.h"

#define KEY_INSTAGRAM_DICTIONARY @"data"
#define KEY_INSTAGRAM_ATTRIBUTION @"attribution"
#define KEY_INSTAGRAM_CAPTION @"caption"
#define KEY_INSTAGRAM_COMMENTS @"comments"
#define KEY_INSTAGRAM_CREATED_TIME @"created_time"
#define KEY_INSTAGRAM_ID @"id"
#define KEY_INSTAGRAM_IMAGES @"images"
#define KEY_INSTAGRAM_LOW_RESOLUTION @"low_resolution"
#define KEY_INSTAGRAM_STANDARD_RESOLUTION @"standard_resolution"
#define KEY_INSTAGRAM_URL @"url"
#define KEY_INSTAGRAM_HEIGHT @"height"
#define KEY_INSTAGRAM_WIDTH @"width"
#define KEY_INSTAGRAM_THUMBNAIL @"thumbnail"
#define KEY_INSTAGRAM_LIKES @"likes"
#define KEY_INSTAGRAM_COUNT @"count"
#define KEY_INSTAGRAM_LINK @"link"
#define KEY_INSTAGRAM_LOCATION @"location"
#define KEY_INSTAGRAM_LATITUDE @"latitude"
#define KEY_INSTAGRAM_LONGITUDE @"longitude"
#define KEY_INSTAGRAM_NAME @"name"
#define KEY_INSTAGRAM_TAGS @"tags"
#define KEY_INSTAGRAM_TYPE_VIDEO @"video"
#define KEY_INSTAGRAM_TYPE_IMAGE @"image"
#define KEY_INSTAGRAM_USER @"user"
#define KEY_INSTAGRAM_FULL_NAME @"full_name"
#define KEY_INSTAGRAM_PROFILE_PICTURE @"profile_picture"
#define KEY_INSTAGRAM_USERNAME @"username"
#define KEY_INSTAGRAM_VIDEOS @"videos"
#define KEY_INSTAGRAM_LOW_BANDWIDTH @"low_bandwidth"


@interface InstagramManager()
@property (nonatomic, strong) InstagramFeed* instagramFeed;
@end


@implementation InstagramManager


-(id)initWithEngine
{
    self = [self initWithEngineHostName:nil andClientID:nil andClientSecret:nil];
    
    if (!self) {
        return nil;
    }
    
    return self;
}

-(id)initWithEngineHostName:(NSString *)hostName andClientID:(NSString *)cID andClientSecret:(NSString *)cSecret
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.engine = [[InstagramEngine alloc] initWithHostName:hostName andClientID:cID andClientSecret:cSecret];
    
    self.instagramFeed = [[InstagramFeed alloc] init];
    
    return self;
}

-(NSString *)getAuthorizationURL_String
{
    return [self.engine constructAuthorizationURLString];
}

-(NSString *)getAPI_URI
{
    return [self.engine getAPI_Redirect_URI];
}

-(NSArray*)getInstaObjs
{
    return self.instagramFeed.list.copy;
}

-(NSInteger)totalObjectCount
{
    return self.instagramFeed.totalCount;
}

-(InstagramObject *)instaAtIndex:(NSUInteger)index
{
    NSArray* currentList = [self.instagramFeed getCurrentList];
    
    if (currentList != nil) {
        
        InstagramObject* obj = [currentList objectAtIndex:index];
        return obj;
    }
    else{
        return nil;
    }
}

-(void)pullUserInfo
{
    NSString* url = [self.engine constructUserURLString];
    
    [self.engine sendInstagramRequest:url withCompletionHandler:^(NSData *response) {
        
        if (!response) {
            [self.delegate instagramRequestError];
        }
        else
        {
            NSDictionary *responseDict = (NSDictionary*) response;
            
            NSArray* instaObjs = [responseDict objectForKey:KEY_INSTAGRAM_DICTIONARY];
            
            for (NSDictionary* obj in instaObjs) {
                
                InstagramObject* insta = [[InstagramObject alloc] init];
                
                NSString* instagramLink = [obj valueForKey:KEY_INSTAGRAM_LINK];
                
                NSURL* instaURL = [[NSURL alloc] initWithString:instagramLink];
                
                CGFloat preferredHeight;
                
                if ([obj valueForKey:KEY_INSTAGRAM_IMAGES]) {
                    NSDictionary* images = [obj valueForKey:KEY_INSTAGRAM_IMAGES];
                    NSDictionary* standardResolution = [images valueForKey:KEY_INSTAGRAM_STANDARD_RESOLUTION];
                    
                    id height = [standardResolution valueForKey:KEY_INSTAGRAM_HEIGHT];
                    
                    if (height) {
                        preferredHeight = [height floatValue];
                    }
                    
                    [insta setImages:images];
                    [insta setHeight:preferredHeight];
                }
                
                if ([obj valueForKey:KEY_INSTAGRAM_VIDEOS]) {
                    NSDictionary* videos = [obj valueForKey:KEY_INSTAGRAM_VIDEOS];
                    NSDictionary* standardResolution = [videos valueForKey:KEY_INSTAGRAM_STANDARD_RESOLUTION];
                    
                    id height = [standardResolution valueForKey:KEY_INSTAGRAM_HEIGHT];
                    
                    if (height) {
                        preferredHeight = [height floatValue];
                    }
                    
                    [insta setVideos:videos];
                    [insta setHeight:preferredHeight];
                }
                
                [insta setLink:instaURL];
                
                [self.instagramFeed addObjectToFeed:insta];
                
            }
        }
        
            [self.delegate instagramUserInfoRetrieved];
        
    }];
}

-(void)pullRecentFeed
{
    NSString* url = [self.engine constructRecentMediaURLString];
    
    [self.engine sendInstagramRequest:url withCompletionHandler:^(NSData *response) {
        
        if (!response) {
            [self.delegate instagramRequestError];
        }
        else
        {
            
        }
        
    }];
    
}




@end
