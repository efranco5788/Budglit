//
//  PSEditZipcodeOfflineTableViewController.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSAllDealsTableViewController;
@class AppDelegate;
@class CityDataObject;
@class ZipcodeSearchDataSource;

@protocol EditZipcodeOfflineDelegate <NSObject>
@optional
-(void)locationUpdated;
-(void)dismissZipcodeController;
@end

@interface PSEditZipcodeOfflineTableViewController : UITableViewController<UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate>

@property (nonatomic, strong) UISearchController* searchControl;

@property (nonatomic, strong) ZipcodeSearchDataSource* dataSource;

@property (nonatomic, strong) id<EditZipcodeOfflineDelegate> delegate;

@property (strong, nonatomic) NSString* currentZipcode;

@property (strong, nonatomic) UIBarButtonItem* cancelButton;

-(void) hideBackButton:(BOOL)hide;

-(void) cancelButton_pressed:(UIBarButtonItem*)sender;

@end
