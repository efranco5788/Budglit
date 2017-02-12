//
//  MenuTableViewCell.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 5/25/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell
{
    NSInteger menuOption;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMenuOption:(NSInteger)option
{
    menuOption = option;
}

-(NSInteger)getMenuOption
{
    return menuOption;
}

@end
