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

- (instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithEngine;
-(instancetype) initWithEngineHostName:(NSString*)hostName andClientID:(NSString*)cID andClientSecret:(NSString*)cSecret NS_DESIGNATED_INITIALIZER;
-(InstagramObject*)instaAtIndex:(NSUInteger)index;

@property (NS_NONATOMIC_IOSONLY, getter=getAuthorizationURL_String, readonly, copy) NSString *authorizationURL_String;
@property (NS_NONATOMIC_IOSONLY, getter=getAPI_URI, readonly, copy) NSString *API_URI;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger totalObjectCount;
@property (NS_NONATOMIC_IOSONLY, getter=getInstaObjs, readonly, copy) NSArray *instaObjs;

-(void)pullRecentFeed;

-(void)pullUserInfo;

@end
