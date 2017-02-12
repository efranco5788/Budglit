//
//  InstagramManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/1/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramEngine.h"

@class InstagramFeed;
@class InstagramObject;

@protocol InstagramManagerDelegate <NSObject>
@optional
-(void)instagramAccessTokenGranted;
-(void)instagramUserInfoRetrieved;
-(void)instagramFilteredTweetsReturned;
-(void)instagramRequestError;
@end

@interface InstagramManager : NSObject

@property (nonatomic, strong) InstagramEngine* engine;
@property (nonatomic, strong) InstagramFeed* filteredTmpInstaFeed;
@property (nonatomic, strong) id <InstagramManagerDelegate> delegate;

-(id)initWithEngine;

-(id) initWithEngineHostName:(NSString*)hostName andClientID:(NSString*)cID andClientSecret:(NSString*)cSecret;

-(InstagramObject*)instaAtIndex:(NSUInteger)index;

-(NSString*)getAuthorizationURL_String;

-(NSString*)getAPI_URI;

-(NSInteger)totalObjectCount;

-(NSArray*)getInstaObjs;

-(void)pullRecentFeed;

-(void)pullUserInfo;

@end
