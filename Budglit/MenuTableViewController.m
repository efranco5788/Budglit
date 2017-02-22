//
//  MenuTableViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 2/21/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MenuTableViewCell.h"
#import "LocationServiceManager.h"
#import "MenuOptions.h"
#import "UserAccount.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_SECTION_DEFAULT_HEIGHT 44
#define MAX_SECTION_LOGIN_HEIGHT 0.30
#define MAX_SECTION_SECOND_HEIGHT 0.60
#define MAX_SECTION_THIRD_HEIGHT 5
#define RESTORATION_STRING @"menuTableViewController"

@interface MenuTableViewController ()

@end

static NSString *CellIdentifier = @"Cell";

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:NSLocalizedString(@"USER_CHANGED_NOTIFICATION", nil) object:nil];
    
    [self.tableView registerClass:[MenuTableViewCell self] forCellReuseIdentifier:CellIdentifier];
    
    self.restorationIdentifier = RESTORATION_STRING;
}

-(void)updateUser:(MenuTableViewCell*)cell;
{
    
    if(![cell isKindOfClass:[MenuTableViewCell class]])
    {
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        
        cell = (MenuTableViewCell*) [self.tableView cellForRowAtIndexPath:path];
    }
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UserAccount* user = [appDelegate.accountManager getSignedAccount];
    
    UIImage* image = [user getProfileImage];
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.masksToBounds = YES;
    
    [cell.imageView setImage:image];
    
    cell.textLabel.text = user.firstName;
}

#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
    {
        return 1;
    }
    
    if (section == 1) {
        return 3;
    }
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            //CGFloat additionalHeight = (MAX_SECTION_DEFAULT_HEIGHT * MAX_SECTION_LOGIN_HEIGHT);
            //CGFloat newHeight = (additionalHeight + MAX_SECTION_DEFAULT_HEIGHT);
            //return newHeight;
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
            CGFloat additionalHeight = (MAX_SECTION_DEFAULT_HEIGHT * MAX_SECTION_THIRD_HEIGHT);
            CGFloat newHeight = (additionalHeight + MAX_SECTION_DEFAULT_HEIGHT);
            return newHeight;
            break;
        }
        default:
        {
            return MAX_SECTION_DEFAULT_HEIGHT;
            break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    
    return 44;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] init];
        [headerView setBackgroundColor:[UIColor blueColor]];
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuTableViewCell* cell = (MenuTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // First cell contains signed user's info
    if (indexPath.section == 0) {
        /*
         AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
         
         UserAccount* user = [appDelegate.accountManager getSignedAccount];
         
         UIImage* image = [user getProfileImage];
         
         cell.imageView.clipsToBounds = YES;
         cell.imageView.layer.masksToBounds = YES;
         //cell.imageView.layer.cornerRadius = 45.0f;
         
         [cell.imageView setImage:image];
         
         cell.textLabel.text = user.firstName;
         */
        
        [self updateUser:cell];
    }
    else if (indexPath.section == 1) {
        
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
    }
    else if (indexPath.section == 2){
        [cell setMenuOption:menuLogout];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"LOGOUT", nil)];
    }
    
    return cell;
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
