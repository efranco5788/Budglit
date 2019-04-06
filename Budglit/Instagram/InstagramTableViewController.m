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
#import "ImageStateObject.h"

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
    
    [self.tableView registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    self.restorationIdentifier = RESTORATION_STRING;
    
    self.mediaDownloadInProgress = [NSMutableDictionary dictionary];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)viewDidAppear:(BOOL)animated
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    (databaseManager).delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    [databaseManager setDelegate:nil];
}

#pragma mark -
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    return [instagramManager totalObjectCount];
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    NSArray* objs = [instagramManager getInstaObjs];
    
    InstagramObject* instaObj = objs[indexPath.row];
    
    return [instaObj getHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    NSArray* list = instagramManager.getInstaObjs;
    
    InstagramObject* obj = list[indexPath.row];
    
    InstagramTableViewCell* cell = (InstagramTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    (cell.instaUsername).text = obj.username;
    
    (cell.captionLbl).text = obj.caption;
    
    cell.instaImageView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    NSArray* objs = [instagramManager getInstaObjs];
    
    InstagramTableViewCell* instaCell = (InstagramTableViewCell*) cell;
    
    InstagramObject* instaObj = objs[indexPath.row];
    
    [instaCell.activityIndicator startAnimating];
    
    [self startImageDownloadForInstaObj:instaObj forIndexPath:indexPath andTableCell:instaCell];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];

    NSArray* objs = [instagramManager getInstaObjs];
    
    InstagramObject* instaObj = objs[indexPath.row];
    
    if (instaObj.avPlayer) {
        [instaObj.avPlayer pause];
    }
}

#pragma mark -
#pragma mark - Image Handling Methods
-(void) startImageDownloadForInstaObj:(InstagramObject*)obj forIndexPath:(NSIndexPath*)indexPath andTableCell:(InstagramTableViewCell*)cell
{
    InstagramObject* fetchingMediaForIG = (self.mediaDownloadInProgress)[indexPath];
    
    if (fetchingMediaForIG == nil) {

        DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        //(self.mediaDownloadInProgress)[indexPath] = obj;
        
        // Background Thread Queue
        dispatch_async(backgroundQueue, ^{
            
            [databaseManager managerStartDownloadImageFromURL:obj.userImgURLString forObject:nil forIndexPath:indexPath imageView:cell.instaUserProfile addCompletion:nil];
            
            if ([obj.type isEqualToString:KEY_INSTAGRAM_TYPE_VIDEO]) {
                /*
                fetchingMediaForIG.avPlayer = [[AVPlayer alloc] initWithURL:fetchingMediaForIG.link];
                NSLog(@"Link %@", fetchingMediaForIG.link);
                fetchingMediaForIG.playerLayer = [AVPlayerLayer playerLayerWithPlayer:fetchingMediaForIG.avPlayer];
                [fetchingMediaForIG.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
                
                dispatch_async(dispatch_get_main_queue(), ^{ // Run on the main queue
                    
                    CGRect parentViewSize = cell.contentView.frame;
                    CGRect frameSize = CGRectMake(cell.superview.frame.origin.x, cell.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
                    [fetchingMediaForIG.playerLayer setFrame:frameSize];
                    [fetchingMediaForIG.playerLayer setBackgroundColor:[[UIColor greenColor] CGColor]];
                    UITapGestureRecognizer* tap = [UITapGestureRecognizer alloc];
                    [tap addTarget:fetchingMediaForIG action:@selector(toggleMuteButton)];
                    UIView* underview = [[UIView alloc] initWithFrame:fetchingMediaForIG.getMediaFrame];
                    [underview setBackgroundColor:[UIColor whiteColor]];
                    [underview addGestureRecognizer:tap];
                    [cell.layer addSublayer:fetchingMediaForIG.playerLayer];
                    [cell.layer addSublayer:underview.layer];
                    fetchingMediaForIG.avPlayer.muted = YES;
                    [fetchingMediaForIG.avPlayer play];
                    
                    NSLog(@"Frame is %@", underview);
                    
                });
                 */
 
            }
            else if ([obj.type isEqualToString:KEY_INSTAGRAM_TYPE_IMAGE]) {
                
                (self.mediaDownloadInProgress)[indexPath] = obj;
                
                [databaseManager managerStartDownloadImageFromURL:obj.link.absoluteString forObject:obj forIndexPath:indexPath imageView:cell.instaImageView addCompletion:nil];

            }
            
        });
        
    }
    
}

-(void)loadOnScreenCells
{
    InstagramManager* instagramManager = [InstagramManager sharedInstagramManager];
    
    NSArray* instaObjs = [NSArray arrayWithArray:[instagramManager getInstaObjs]];
    
    if (instaObjs.count > 0) {
        
        InstagramTableViewController* __weak weakSelf = self;
        
        NSArray* visibleOnScreenDeals = (weakSelf.tableView).visibleCells;
        
        for (InstagramTableViewCell* visibleCell in visibleOnScreenDeals) {
            
            NSIndexPath* index = [self.tableView indexPathForCell:visibleCell];
            
            __block InstagramObject* visibleObj = instaObjs[index.row];
            
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
        [self loadOnScreenCells];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadOnScreenCells];
}


#pragma mark -
#pragma mark - Table View Cell Delegate
-(void)loadedForObject:(InstagramObject *)obj
{
    //[self.mediaDownloadInProgress removeObjectForKey:obj.path];
    
}

#pragma mark -
#pragma mark - Database Manager Delegate
/*
-(void)imageFetchedForDeal:(Deal*)deal forIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSArray* instaObjs = [NSArray arrayWithArray:[appDelegate.instagramManager getInstaObjs]];
    
    InstagramObject* obj = [instaObjs objectAtIndex:indexPath.row];
    
    [obj.imgView setImage:image];
    
    [self.mediaDownloadInProgress removeObjectForKey:indexPath];
}
*/
-(void)imageFetchedForObject:(id)obj forIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image andImageView:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        InstagramTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if(cell){
            
            if (obj) {
                
                [cell.instaImageView setHidden:NO];
                
                CATransition* transition = [CATransition animation];
                transition.duration = 0.1f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.type = kCATransitionFade;
                
                [cell.instaImageView.layer addAnimation:transition forKey:nil];
                
                (cell.instaImageView).image = image;
                
                [self.mediaDownloadInProgress removeObjectForKey:indexPath];
            }
            else imageView.image = image;
            
            
        }
        
    });
}

#pragma mark -
#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
