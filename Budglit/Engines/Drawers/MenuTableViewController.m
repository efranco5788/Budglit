//
//  MenuTableViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 2/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AppDelegate.h"
#import "AccountMenuTableViewController.h"
#import "DrawerViewController.h"
#import "MenuTableViewCell.h"
#import "LocationServiceManager.h"
#import "MenuOptions.h"
#import "UserAccount.h"
#import "UserProfileTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_SECTION_DEFAULT_HEIGHT 44
#define MAX_SECTION_LOGIN_HEIGHT 0.30
#define MAX_SECTION_SECOND_HEIGHT 0.60
#define MAX_SECTION_THIRD_HEIGHT 0.55
#define MAX_USER_ROW_HEIGHT 120
#define RESTORATION_STRING @"menuTableViewController"

@interface MenuTableViewController () <DrawerControllerDelegate, MenuAccountDelegate>

@end

static NSString *cellIdentifier = @"cell";
static NSString *userProfileIdentifier = @"profileCell";

@implementation MenuTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:kDefaultNotificationProfileCellDrawn object:nil];
    
    [self.tableView registerClass:[MenuTableViewCell self] forCellReuseIdentifier:cellIdentifier];
    
    [self.tableView registerClass:[UserProfileTableViewCell self] forCellReuseIdentifier:userProfileIdentifier];
    
    self.restorationIdentifier = RESTORATION_STRING;
}

-(void)viewDidAppear:(BOOL)animated
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DrawerViewController* drawer = [storyboard instantiateViewControllerWithIdentifier:NSLocalizedString(@"MENU_DRAWER_CONTROLLER", nil)];
    
    [drawer setDelegate:self];
}

-(BOOL)prefersStatusBarHidden
{
    [super prefersStatusBarHidden];
    
    return NO;
}

-(void)updateUser:(NSNotification*)notification
{
    AccountManager* accountManager = [AccountManager sharedAccountManager];
    
    UserAccount* user = [accountManager managerSignedAccount];
    
    UserProfileTableViewCell* profileCell = (UserProfileTableViewCell*) notification.object;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if(!profileCell) profileCell = [self.tableView cellForRowAtIndexPath:indexPath];

    (profileCell.textLabel).text = user.firstName;
    
    (profileCell.detailTextLabel).text = @"Testing";
    
    UIImage* image = [user getProfileImage];
    
    (profileCell.imageView).image = image;
    
    [profileCell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [profileCell.imageView setClipsToBounds:YES];
}


#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            //CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            
            return 0.0f;
            //return statusBarFrame.size.height;
            break;
        }
        case 1:
        {
            CGFloat additionalHeight = (MAX_SECTION_DEFAULT_HEIGHT * MAX_SECTION_SECOND_HEIGHT);
            CGFloat newHeight = (additionalHeight + MAX_SECTION_DEFAULT_HEIGHT);
            return newHeight;
            break;
        }
        case 2:
        {
            CGFloat startingHeight = (self.view.frame.size.height - ((MAX_SECTION_DEFAULT_HEIGHT * MAX_SECTION_SECOND_HEIGHT) + MAX_SECTION_DEFAULT_HEIGHT));
            
            CGFloat rowsIncludedHeight = startingHeight - (MAX_USER_ROW_HEIGHT + (MAX_SECTION_DEFAULT_HEIGHT * 4));
            
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            CGFloat postFinalHeight = (rowsIncludedHeight - MAX_SECTION_DEFAULT_HEIGHT) - (statusBarFrame.size.height * 2);
            
            CGFloat finalHeight = postFinalHeight + statusBarFrame.size.height;
            
            return finalHeight;
            break;
        }
        default:
        {
            return 0;
            break;
        }
    }

}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [view setTintColor:[appDelegate getPrimaryColor]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return MAX_USER_ROW_HEIGHT;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // First cell contains signed user's info
    if (indexPath.section == 0) {
        
        UserProfileTableViewCell* cell = (UserProfileTableViewCell*) [tableView dequeueReusableCellWithIdentifier:userProfileIdentifier];
        
        CGRect frame = CGRectMake(15, 30, MAX_USER_ROW_HEIGHT - 60, MAX_USER_ROW_HEIGHT - 60);
        (cell.imageView).bounds = frame;
        (cell.imageView).frame = frame;

        CGRect labelFrame = CGRectMake((frame.size.width + 30), (MAX_USER_ROW_HEIGHT / 2) - 30, (cell.frame.size.width / 2), (cell.frame.size.height / 2));
        
        (cell.textLabel).frame = labelFrame;
        
        [cell.imageView.layer setMasksToBounds:YES];
        (cell.imageView.layer).cornerRadius = (cell.imageView.frame.size.width / 2.5);
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.contentMode = UIViewContentModeScaleAspectFit;
  
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [cell setBackgroundColor:[appDelegate getPrimaryColor]];
        
        [cell setMenuOption:MENUACCOUNT];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if (indexPath.section == 1) {
        
        MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        NSInteger menuValue = (indexPath.row + 1);
        
        if (menuValue == MENUSWITCHMODE) {
            [cell setMenuOption:MENUSWITCHMODE];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"LIST_MODE", nil)];
            cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0];
        }
        
        if (menuValue == MENUCURRENTLOCATION) {
            [cell setMenuOption:MENUCURRENTLOCATION];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"USE_CURRENT_LOCATION", nil)];
            cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0];
        }
        
        if (menuValue == MENUCHANGELOCATION) {
            [cell setMenuOption:MENUCHANGELOCATION];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"CHANGE_LOCATION", nil)];
            cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0];
        }

        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [cell setBackgroundColor:[appDelegate getPrimaryColor]];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if (indexPath.section == 2){
        
        MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        [cell setMenuOption:MENULOGOUT];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"LOGOUT", nil)];
        
        cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0];
        
        AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        [cell setBackgroundColor:[appDelegate getPrimaryColor]];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

// Method called when user selects a row from menu
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped");
    
    MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger option = cell.getMenuOption;
    
    [self.delegate menuSelected:option];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - Account Menu Methods
-(void)presentAccountMenuTable
{
    if(!self.accountTable)
    {
        self.accountTable = [[AccountMenuTableViewController alloc] init];
    }
    
     self.accountTable.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.accountTable setDelegate:self];
    
    [self addChildViewController:self.accountTable];
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    [self.accountTable.view setFrame:CGRectMake(self.view.bounds.size.width, (0 - statusBarFrame.size.height), self.view.bounds.size.width, self.view.bounds.size.height)];
    
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.accountTable.view setFrame:self.view.bounds];
        [self.view addSubview:self.accountTable.view];
        
    } completion:^(BOOL finished) {
        
       [self.accountTable didMoveToParentViewController:self];
        
        if (@available(iOS 11, *)) {
            
            UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
            
            [self.accountTable.view.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
            [self.accountTable.view.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
            [self.accountTable.view.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
            [self.accountTable.view.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
            
        } else {
            
            UILayoutGuide *margins = self.view.layoutMarginsGuide;
            
            [self.accountTable.view.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
            [self.accountTable.view.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
            [self.accountTable.view.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
            [self.accountTable.view.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
            
        }
    }];
    
}

-(void)dissmissMenuAccountView
{
    //[self.accountTable.view removeFromSuperview];
    //[self.accountTable removeFromParentViewController];

    [UIView animateWithDuration:0.5f animations:^{
        
        [self.accountTable.view setFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
    } completion:^(BOOL finished) {
        [self.accountTable.view removeFromSuperview];
        [self.accountTable removeFromParentViewController];
        self.accountTable = nil;
    }];
    
}

#pragma mark -
#pragma mark - Memory Managment Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDefaultNotificationProfileCellDrawn object:nil];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

/*
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
 
 if(indexPath.section == MMDrawerSectionDrawerWidth){
 [self.mm_drawerController
 setMaximumRightDrawerWidth:[self.drawerWidths[indexPath.row] floatValue]
 animated:YES
 completion:^(BOOL finished) {
 [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
 [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
 [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }];
 }
 else {
 [self tableView:tableView didSelectRowAtIndexPath:indexPath];
 }
 
 
 
 
 }
 */
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
