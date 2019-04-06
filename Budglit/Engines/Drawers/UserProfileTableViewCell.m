//
//  UserProfileTableViewCell.m
//  Budglit
//
//  Created by Emmanuel Franco on 6/28/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "UserProfileTableViewCell.h"

@implementation UserProfileTableViewCell
{
    NSInteger menuOption;
}

NSString* const kDefaultNotificationProfileCellDrawn = @"profileCellDrawnNotification";

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    //[super layoutSubviews];
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter postNotificationName:kDefaultNotificationProfileCellDrawn object:self userInfo:nil];
}

-(void)setMenuOption:(NSInteger)option
{
    menuOption = option;
}

-(NSInteger)getMenuOption
{
    return menuOption;
}


-(void)dealloc
{
    
}

@end
