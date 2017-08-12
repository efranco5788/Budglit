//
//  MenuTableViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 2/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "MenuTableViewController.h"
#import "DrawerViewController.h"
#import "MenuTableViewCell.h"
#import "LocationServiceManager.h"
#import "MenuOptions.h"
#import "UserAccount.h"
#import "UserProfileTableViewCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_SECTION_DEFAULT_HEIGHT 44
#define MAX_SECTION_LOGIN_HEIGHT 0.30
#define MAX_SECTION_SECOND_HEIGHT 0.60
#define MAX_SECTION_THIRD_HEIGHT 0.55
#define MAX_USER_ROW_HEIGHT 60
#define RESTORATION_STRING @"menuTableViewController"

@interface MenuTableViewController ()

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

-(void)updateUser:(NSNotification*)notification
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UserAccount* user = [appDelegate.accountManager getSignedAccount];
    
    UserProfileTableViewCell* profileCell = (UserProfileTableViewCell*) notification.object;

    [profileCell.textLabel setText:user.firstName];
    
    UIImage* image = [user getProfileImage];
    
    [profileCell.imageView setImage:image];
}


#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    }
    
    if (section == 1) {
        return 3;
    }
    
    if (section == 2) {
        return 1;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 0.1f;
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
            
            CGFloat rowsIncludedHeight = startingHeight - (MAX_USER_ROW_HEIGHT + (MAX_SECTION_DEFAULT_HEIGHT * 3));
            
            CGFloat finalHeight = rowsIncludedHeight - MAX_SECTION_DEFAULT_HEIGHT;
            
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
        
        UserProfileTableViewCell* cell = (UserProfileTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:userProfileIdentifier];
        
        CGRect frame = CGRectMake(10, 0, MAX_USER_ROW_HEIGHT, MAX_USER_ROW_HEIGHT);
        [cell.imageView setBounds:frame];
        [cell.imageView setFrame:frame];
        
        CGRect labelFrame = CGRectMake((frame.size.width + 20), cell.center.y, (cell.frame.size.width / 2), (cell.frame.size.height / 2));
        
        [cell.textLabel setFrame:labelFrame];
        
        [cell.imageView.layer setMasksToBounds:YES];
        [cell.imageView.layer setCornerRadius:(cell.imageView.frame.size.width / 2)];
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        [cell setContentMode:UIViewContentModeScaleAspectFit];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        
        MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        if (indexPath.row == menuCurrentLocation) {
            [cell setMenuOption:menuCurrentLocation];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"USE_CURRENT_LOCATION", nil)];
        }
        
        if (indexPath.row == menuChangeLocation) {
            [cell setMenuOption:menuChangeLocation];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"CHANGE_LOCATION", nil)];
        }
        
        if (indexPath.row == menuChangeBudget) {
            [cell setMenuOption:menuChangeBudget];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"EDIT_MY_BUDGET", nil)];
        }
        
        return cell;
    }
    else if (indexPath.section == 2){
        MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        [cell setMenuOption:menuLogout];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"LOGOUT", nil)];
        
        return cell;
    }
    
    return nil;
    //else cell.textLabel.text = [NSString stringWithFormat:@"%li", (long)indexPath.section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger option = cell.getMenuOption;
    
    [self.delegate menuSelected:option];
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
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
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
