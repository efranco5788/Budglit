//
//  MenuTableViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 5/16/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"

@class MenuTableViewCell;

@protocol MenuViewDelegate <NSObject>
@optional
-(void)menuSelected:(NSInteger)menuOption;
@end

/*
typedef NS_ENUM(NSInteger, menuSection){
    menuCurrentLocation = 0,
    menuChangeLocation = 1,
    menuChangeBudget = 2,
    menuLogout = 3
};
*/
typedef NS_ENUM(NSInteger, MMDrawerSection){
    MMDrawerSectionViewSelection,
    MMDrawerSectionDrawerWidth,
    MMDrawerSectionShadowToggle,
    MMDrawerSectionOpenDrawerGestures,
    MMDrawerSectionCloseDrawerGestures,
    MMDrawerSectionCenterHiddenInteraction,
    MMDrawerSectionStretchDrawer,
};

@interface MenuTableViewController : UITableViewController

@property (nonatomic, assign) id<MenuViewDelegate> delegate;

@property (nonatomic,strong) NSArray * drawerWidths;

@end
