//
//  InstagramTableViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/11/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramTableViewController.h"
#import "AppDelegate.h"
#import "InstagramObject.h"
#import "InstagramTableViewCell.h"

#define RESTORATION_STRING @"instagramTableViewController"

@interface InstagramTableViewController ()<InstaTableViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary* mediaDownloadInProgress;

@end

static NSString* const reuseIdentifier = @"InstagramTableViewCell";

@implementation InstagramTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[InstagramTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    self.restorationIdentifier = RESTORATION_STRING;
    
    self.mediaDownloadInProgress = [[NSMutableDictionary alloc] init];
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGRect frameSize = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, screenSize.size.width, self.tableView.frame.size.height);
    
    [self.tableView setFrame:frameSize];
}

#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    return [appDelegate.instagramManager totalObjectCount];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInteger nodeCount = appDelegate.instagramManager.totalObjectCount;
    
    InstagramTableViewCell* instaCell = nil;
    
    if (nodeCount == 0 && indexPath.row == 0) {
        
    }
    else
    {
        instaCell = (InstagramTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        [instaCell setDelegate:self];
        
        CGRect barFrame = self.navigationController.navigationBar.frame;
        CGRect containerBounds = [self.view bounds];
        CGRect newInsetFrame = CGRectInset(containerBounds, barFrame.origin.x, barFrame.origin.y);
        CGRect newFrame = CGRectOffset(newInsetFrame, barFrame.origin.x, barFrame.origin.y);
        
        [instaCell setFrame:newFrame];
        
        [instaCell configure];
        
    }
    
    return instaCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInteger nodeCount = appDelegate.instagramManager.totalObjectCount;
    
    NSArray* objs = [appDelegate.instagramManager getInstaObjs];
    
    if (nodeCount > 0) {
        
        InstagramObject* instaObj = [objs objectAtIndex:indexPath.row];
        
        InstagramTableViewCell* instaCell = (InstagramTableViewCell*)cell;
        
        //[instaCell setIndex:indexPath];
        
        [self startImageDownloadForInstaObj:instaObj forIndexPath:indexPath andTableCell:instaCell];
        
        //[instaCell beginLoadingReuqest:instaObj.link];
        
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    InstagramObject* instaObj = (InstagramObject*) [appDelegate.instagramManager instaAtIndex:indexPath.row];

    return [instaObj getHeight];
}

#pragma mark -
#pragma mark - Image Handling Methods
-(void) startImageDownloadForInstaObj:(InstagramObject*)obj forIndexPath:(NSIndexPath*)indexPath andTableCell:(InstagramTableViewCell*)cell
{
    __block InstagramObject* fetchingMediaForIG = (self.mediaDownloadInProgress)[indexPath];
    
    if (fetchingMediaForIG == nil) {
        
        fetchingMediaForIG = obj;
        
        fetchingMediaForIG.path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        dispatch_queue_t backgroundQueue;
        
        backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        // Background Thread Queue
        dispatch_async(backgroundQueue, ^{
            
            // Start the acitivty indicator on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{[cell.activityIndicator startAnimating]; });
            
            [cell beginLoadingReuqest:fetchingMediaForIG];
            
        });
        
        (self.mediaDownloadInProgress)[indexPath] = obj;
        
    }
}

-(void)loadOnScreenDealImages
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* instaObjs = [NSArray arrayWithArray:[appDelegate.instagramManager getInstaObjs]];
    
    if (instaObjs.count > 0) {
        
        InstagramTableViewController* __weak weakSelf = self;
        
        NSArray* visibleOnScreenDeals = [weakSelf.tableView visibleCells];
        
        for (InstagramTableViewCell* visibleCell in visibleOnScreenDeals) {
            
            NSIndexPath* index = [self.tableView indexPathForCell:visibleCell];
            
            __block InstagramObject* visibleObj = [instaObjs objectAtIndex:index.row];
            
            if ([visibleCell.webView isHidden]) {
                
                [weakSelf startImageDownloadForInstaObj:visibleObj forIndexPath:index andTableCell:visibleCell];
            }
        }
    }
}

#pragma mark -
#pragma mark - Scroll View Delegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self loadOnScreenDealImages];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadOnScreenDealImages];
}


#pragma mark -
#pragma mark - Table View Cell Delegate
-(void)webViewLoadedForObject:(InstagramObject *)obj
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        InstagramTableViewCell* instaCell = (InstagramTableViewCell*) [self.tableView cellForRowAtIndexPath:obj.path];
        
        [instaCell.activityIndicator stopAnimating];
        
        [self.mediaDownloadInProgress removeObjectForKey:obj.path];
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.1f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        
        [instaCell.webView.layer addAnimation:transition forKey:nil];
        
        [instaCell displayInstagramView];
        
    });
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
