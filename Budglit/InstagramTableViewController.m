//
//  InstagramTableViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 3/4/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramTableViewController.h"
#import "AppDelegate.h"
#import "InstagramObject.h"
#import "InstagramTableViewCell.h"

#define RESTORATION_STRING @"instagramTableViewController"
#define KEY_INSTAGRAM_TYPE @"type"
#define KEY_INSTAGRAM_TYPE_VIDEO @"video"
#define KEY_INSTAGRAM_TYPE_IMAGE @"image"

@interface InstagramTableViewController ()<InstaTableViewCellDelegate, DatabaseManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary* mediaDownloadInProgress;

@end

static NSString* const reuseIdentifier = @"InstagramTableViewCell";
//static NSString* const reuseIdentifier = @"InstagramCell";

@implementation InstagramTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[InstagramTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    self.restorationIdentifier = RESTORATION_STRING;
    
    self.mediaDownloadInProgress = [NSMutableDictionary dictionary];
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGRect frameSize = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenSize.size.width, self.tableView.frame.size.height);
    
    [self.tableView setFrame:frameSize];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)viewDidAppear:(BOOL)animated
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager setDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.databaseManager setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInteger nodeCount = appDelegate.instagramManager.totalObjectCount;
    
    if (nodeCount < 1 && indexPath.row < 1) {
        return nil;
    }
    else
    {
        InstagramTableViewCell* cell = (InstagramTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        CGRect barFrame = self.navigationController.navigationBar.frame;
        CGRect containerBounds = [self.view bounds];
        CGRect newInsetFrame = CGRectInset(containerBounds, barFrame.origin.x, barFrame.origin.y);
        CGRect newFrame = CGRectOffset(newInsetFrame, barFrame.origin.x, barFrame.origin.y);
        
        [cell setFrame:newFrame];
        
        [cell configure];
        
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 800;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSInteger nodeCount = appDelegate.instagramManager.totalObjectCount;
    
    NSArray* objs = [appDelegate.instagramManager getInstaObjs];
    
    if (nodeCount > 0) {
        
        InstagramTableViewCell* instaCell = (InstagramTableViewCell*) cell;
        
        InstagramObject* instaObj = [objs objectAtIndex:indexPath.row];
        
        [self startImageDownloadForInstaObj:instaObj forIndexPath:indexPath andTableCell:instaCell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    InstagramTableViewCell* instaCell = (InstagramTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [instaCell cellDidDisappear];
    */
    
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* objs = [appDelegate.instagramManager getInstaObjs];
    
    InstagramObject* instaObj = [objs objectAtIndex:indexPath.row];
    
    [instaObj.avPlayer pause];
    
}

#pragma mark -
#pragma mark - Image Handling Methods
-(void) startImageDownloadForInstaObj:(InstagramObject*)obj forIndexPath:(NSIndexPath*)indexPath andTableCell:(InstagramTableViewCell*)cell
{
    __block InstagramObject* fetchingMediaForIG = (self.mediaDownloadInProgress)[indexPath];
    
    if (fetchingMediaForIG == nil) {
        
        fetchingMediaForIG = obj;
        
        fetchingMediaForIG.path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        // Background Thread Queue
        dispatch_async(backgroundQueue, ^{// Run on the background queue
            
            if ([fetchingMediaForIG.type isEqualToString:KEY_INSTAGRAM_TYPE_VIDEO]) {
                
                fetchingMediaForIG.avPlayer = [[AVPlayer alloc] initWithURL:fetchingMediaForIG.link];
                NSLog(@"Link %@", fetchingMediaForIG.link);
                fetchingMediaForIG.playerLayer = [AVPlayerLayer playerLayerWithPlayer:fetchingMediaForIG.avPlayer];
                [fetchingMediaForIG.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
                
                dispatch_async(dispatch_get_main_queue(), ^{ // Run on the main queue
                    
                    CGRect parentViewSize = cell.contentView.frame;
                    CGRect frameSize = CGRectMake(cell.superview.frame.origin.x, cell.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
                    [fetchingMediaForIG.playerLayer setFrame:frameSize];
                    [fetchingMediaForIG.playerLayer setBackgroundColor:[[UIColor greenColor] CGColor]];
                    [cell.layer addSublayer:fetchingMediaForIG.playerLayer];
                    [fetchingMediaForIG.avPlayer play];
                    
                });
                
            }
            else if ([fetchingMediaForIG.type isEqualToString:KEY_INSTAGRAM_TYPE_IMAGE]) {
                
                AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                
                fetchingMediaForIG.imgView = [[UIImageView alloc] init];
                
                [appDelegate.databaseManager startDownloadImageFromURL:fetchingMediaForIG.link.absoluteString forIndexPath:indexPath andImageView:fetchingMediaForIG.imgView];
                
                dispatch_async(dispatch_get_main_queue(), ^{ // Run on the main queue
                    
                    CGRect parentViewSize = cell.contentView.frame;
                    CGRect frameSize = CGRectMake(cell.superview.frame.origin.x, cell.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
                    [fetchingMediaForIG.imgView setFrame:frameSize];
                    [fetchingMediaForIG.imgView setContentMode:UIViewContentModeScaleAspectFit];
                    [cell addSubview:fetchingMediaForIG.imgView];
                    [fetchingMediaForIG.imgView setBackgroundColor:[UIColor redColor]];
                });
            }
            
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
            
            [weakSelf startImageDownloadForInstaObj:visibleObj forIndexPath:index andTableCell:visibleCell];
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
-(void)loadedForObject:(InstagramObject *)obj
{
    [self.mediaDownloadInProgress removeObjectForKey:obj.path];
    
}

#pragma mark -
#pragma mark - Database Manager Delegate
-(void)imageFetchedForDeal:(Deal *)deal forIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* instaObjs = [NSArray arrayWithArray:[appDelegate.instagramManager getInstaObjs]];
    
    InstagramObject* obj = [instaObjs objectAtIndex:indexPath.row];
    
    [obj.imgView setImage:image];
    
    [self.mediaDownloadInProgress removeObjectForKey:obj.path];
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
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end