//
//  DealTableViewCell.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTimerLabel/MZTimerLabel.h"

@interface DealTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* dealImage;
@property (strong, nonatomic) IBOutlet UITextView* dealDescription;
@property (weak, nonatomic) IBOutlet UILabel* dealTimer;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView*imageLoadingActivityIndicator;
@property (strong, nonatomic) NSTimer* endTimer;

-(void) animateLabel;
-(void) endAnimationLabel;

@end
