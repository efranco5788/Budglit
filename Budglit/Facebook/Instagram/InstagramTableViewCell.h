//
//  InstagramTableViewCell.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/11/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "InstagramObject.h"

@protocol InstaTableViewCellDelegate <NSObject>
@optional
-(void) loadedForObject:(InstagramObject*)obj;
@end

@interface InstagramTableViewCell : UITableViewCell

@property (strong, nonatomic) id <InstaTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *instaImageView;
@property (strong, nonatomic) IBOutlet UILabel* instaUsername;
@property (strong, nonatomic) IBOutlet UIImageView *instaUserProfile;


//-(void)configure;

-(void)beginLoadingReuqest:(InstagramObject*)obj;

-(void)cellDidDisappear;


@end
