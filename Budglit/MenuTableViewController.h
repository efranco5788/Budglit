//
//  MenuTableViewController.h
//  Budglit
//
//  Created by Emmanuel Franco on 2/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
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
