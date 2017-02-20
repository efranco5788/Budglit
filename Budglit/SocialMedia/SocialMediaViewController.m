//
//  SocialMediaViewController.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/26/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "SocialMediaViewController.h"

@interface SocialMediaViewController ()
{
    NSInteger pageIndex;
}

@end

@implementation SocialMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.delegate viewAppeared:self];
}

-(void)setPageIndex:(NSInteger)pageNum
{
    pageIndex = pageNum;
}

-(NSInteger)getPageIndex
{
    return pageIndex;
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
