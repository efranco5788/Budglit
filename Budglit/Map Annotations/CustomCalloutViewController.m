//
//  CustomCalloutViewController.m
//  Budglit
//
//  Created by Emmanuel Franco on 1/30/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "CustomCalloutViewController.h"

@interface CustomCalloutViewController ()

@end

@implementation CustomCalloutViewController

-(instancetype)init
{
    self = [super init];
    
    if(!self) return nil;
    
    UIScreen* screen = [UIScreen mainScreen];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screen.bounds.size.width, 178.0);
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
