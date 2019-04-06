//
//  AccountMenuTableViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 11/22/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "AccountMenuTableViewController.h"
#import "AppDelegate.h"

@interface AccountMenuTableViewController ()

@end

static NSString *cellIdentifier = @"cell";

@implementation AccountMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setRestorationIdentifier:ACCOUNT_MENU_IDENTIFIER];
    
    [self.view setTag:101];
    
    [self.tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.scrollEnabled = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self.view setBackgroundColor:[appDelegate getPrimaryColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    CGRect cancelAreaRect = CGRectMake((self.view.bounds.size.width - 50), 5, 30, 30);

    UIView* cancelArea = [[UIView alloc] initWithFrame:cancelAreaRect];
    
    [cancelArea setBackgroundColor:[UIColor clearColor]];
    
    cancelArea.layer.masksToBounds = YES;
    
    cancelArea.layer.cornerRadius = 25.0f;
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:cancelArea.bounds];
    
    [cancelBtn addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    cancelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cancelBtn setImage:[UIImage imageNamed:@"cancel_filled.png"] forState:UIControlStateNormal];
    
    [cancelBtn.imageView setBackgroundColor:[UIColor whiteColor]];
    
    [cancelArea addSubview:cancelBtn];
    
    [self.view addSubview:cancelArea];
}


- (IBAction)closeBtnPressed:(id)sender{
    [self.delegate dissmissMenuAccountView];
}

#pragma mark -
#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) return 1;
    
    return 3;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setBackgroundColor:[appDelegate getPrimaryColor]];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    if(indexPath.section == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 1){
        
        if(indexPath.row == 0){
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [cell.textLabel.font fontWithSize:17.0];
            cell.textLabel.text = @"Account Settings";
            
        }
        
    }
    else{
        
        cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0];
        
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"Change Default Picture";
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"Change Password";
            }
                break;
            case 2:
            {
                cell.textLabel.text = @"History";
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1){
        
        switch (indexPath.row) {
            case 0:
                {
                    UIAlertController* photoPickerAlert = [UIAlertController alertControllerWithTitle:@"Select a photo" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    UIAlertAction* selectLibrary = [UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [photoPickerAlert addAction:takePhoto];
                    [photoPickerAlert addAction:selectLibrary];
                    [photoPickerAlert addAction:cancel];
                    
                    [self presentViewController:photoPickerAlert animated:YES completion:nil];
                }
                break;
                
            default:
                break;
        }
        
    }

    
}

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
