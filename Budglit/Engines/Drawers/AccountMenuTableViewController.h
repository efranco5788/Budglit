//
//  AccountMenuTableViewController.h
//  Budglit
//
//  Created by Emmanuel Franco on 11/22/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIImagePickerController;

#define ACCOUNT_MENU_IDENTIFIER @"accountMenuIdentifier"

NS_ASSUME_NONNULL_BEGIN

@protocol MenuAccountDelegate <NSObject>
@optional
-(void) dissmissMenuAccountView;
@end

@interface AccountMenuTableViewController : UITableViewController

@property (nonatomic, assign) id<MenuAccountDelegate> delegate;

@property (nonatomic, strong) UIImagePickerController* imagePicker;

- (IBAction)closeBtnPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
