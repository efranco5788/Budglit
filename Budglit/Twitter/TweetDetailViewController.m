//
//  TweetDetailViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 4/5/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "TweetDetailViewController.h"

#define RESTORATION_STRING @"twitterDetailViewController"

@interface TweetDetailViewController ()

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restorationIdentifier = RESTORATION_STRING;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
