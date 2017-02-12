//
//  TweetTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 10/30/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "TweetTableViewController.h"
#import "AppDelegate.h"
#import "Tweet.h"
#import "TwitterFeed.h"

#define RESTORATION_STRING @"twitterDetailViewController"

@interface TweetTableViewController ()

@end

@implementation TweetTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.restorationIdentifier = RESTORATION_STRING;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGRect frameSize = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, screenSize.size.width, self.tableView.frame.size.height);
    
    [self.tableView setFrame:frameSize];
}

-(void)reloadDataWithNewData
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSUInteger rows = [appDelegate.twitterManager totalTweetsCurrentlyLoaded];
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    Tweet* tweet = (Tweet*) [appDelegate.twitterManager tweetAtIndex:indexPath.row];
    
    TWTRTweetTableViewCell* cell = [[TWTRTweetTableViewCell alloc] init];
    
    [cell configureWithTweet:tweet];
    
    [cell.tweetView setDelegate:self];
    
    [cell.tweetView setShowActionButtons:YES];
    
    [cell.tweetView setShowBorder:YES];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    TWTRTweet* tweet = [appDelegate.twitterManager tweetAtIndex:indexPath.row];
    
    // Grab the height for this cell
    CGFloat height = [TWTRTweetTableViewCell heightForTweet:tweet style:TWTRTweetViewStyleCompact width:CGRectGetWidth(self.view.bounds) showingActions:YES];
    
    return height;
}

-(void)tweetView:(TWTRTweetView *)tweetView didTapProfileImageForUser:(TWTRUser *)user
{
    NSLog(@"Here");
}


-(BOOL)tweetView:(TWTRTweetView *)tweetView shouldDisplayDetailViewController:(TWTRTweetDetailViewController *)controller
{
    [self.tweetTableViewDelegate tableview:self selectedTweetViewController:controller];
    
    return NO;
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
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
