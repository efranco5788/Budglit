//
//  InstagramObject.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/17/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@class ImageStateObject;

@interface InstagramObject : NSObject

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* userImgURLString;
@property (nonatomic, strong) NSString* instagramID;
@property (nonatomic, strong) NSString* attribution;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) NSString* timeCreatedString;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSURL* link;
@property (nonatomic, strong) NSString* likesString;
@property (nonatomic, strong) NSDictionary* comments;
@property (nonatomic, strong) NSDictionary* images;
@property (nonatomic,strong) NSDictionary* videos;
@property (nonatomic, strong) NSDictionary* location;
@property (nonatomic, strong) NSDictionary* tags;
@property (nonatomic, strong) NSIndexPath* path;
@property (nonatomic, strong) NSNumber* objHeight;
@property (nonatomic, strong) UIImageView* imgView;
@property (nonatomic, strong) ImageStateObject* mediaStateHandler;
@property (nonatomic, strong) AVPlayer* avPlayer;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;

-initWithInstagrameID:(NSString*)idInt andAttribution:(NSString*)attri andCaption:(NSString*)cap andTimestamp:(NSInteger)timestamp andType:(NSString*)aType andInstagramLink:(NSString*)linkString andCommnents:(NSDictionary*)instaComments andImages:(NSDictionary*)imgs andVideos:(NSDictionary*)vids andLocation:(NSDictionary*)instaLocation andTags:(NSDictionary*)instaTags;

-(void)recordMedia:(NSHTTPURLResponse*)response andRequest:(NSURLRequest*)request;

-(void)setHeight:(CGFloat)aHeight;

-(CGFloat)getHeight;

-(CGRect)getMediaFrame;

-(void)toggleMuteButton;

@end
