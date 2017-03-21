//
//  InstagramTableViewCell.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/11/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramTableViewCell.h"

@interface InstagramTableViewCell()
@property (nonatomic, strong) InstagramObject* object;
@end

@implementation InstagramTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configure
{
    if (!self.activityIndicator) {
        
        CGRect insetFrame = CGRectInset(self.bounds, 2.0, 2.0);
        CGRect offsetFrame = CGRectOffset(insetFrame, self.frame.size.width, self.frame.size.height);
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:offsetFrame];
        
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        
        [self.contentView addSubview:self.activityIndicator];
    }
    
    [self.activityIndicator stopAnimating];
    
}


-(void)beginLoadingReuqest:(InstagramObject *)obj
{
    
    if (!self.object) {
        self.object = obj;
    }
}

-(void)cellDidDisappear
{
    [self.object.avPlayer pause];
}

@end
