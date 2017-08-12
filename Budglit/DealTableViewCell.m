//
//  DealTableViewCell.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 12/6/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DealTableViewCell.h"

@implementation DealTableViewCell

@synthesize dealDescription, dealImage, imageLoadingActivityIndicator;

/*
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.dealImage = [[UIImageView alloc] init];
        self.dealDescription = [[UITextView alloc] init];
        self.imageLoadingActivityIndicator = [[UIActivityIndicatorView alloc] init];
        
        [self.contentView addSubview:self.dealImage];
        [self.contentView addSubview:self.imageLoadingActivityIndicator];
        [self.contentView addSubview:self.dealDescription];
        
    }
    
    return self;
}
*/

-(void)animateLabel
{
    self.endTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.dealTimer setAlpha:0.0];
        } completion:^(BOOL finished) {
            if (finished) {
                [self.dealTimer setAlpha:1.0];
            }
        }];
        
    }];
    
    [self.endTimer fire];
}

-(void)endAnimationLabel
{
    if (self.endTimer) {
        [self.endTimer invalidate];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
