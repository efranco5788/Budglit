//
//  SocialMediaViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/26/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialMediaViewDelegate <NSObject>
@optional
-(void)viewAppeared:(UIViewController*)presentViewController;
@end

@interface SocialMediaViewController : UIViewController

@property (nonatomic, strong) id <SocialMediaViewDelegate> delegate;


@property (NS_NONATOMIC_IOSONLY, getter=getPageIndex) NSInteger pageIndex;

@end
