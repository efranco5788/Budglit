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

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
