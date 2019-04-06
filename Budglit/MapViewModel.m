//
//  MapViewModel.m
//  Budglit
//
//  Created by Emmanuel Franco on 2/23/19.
//  Copyright © 2019 Emmanuel Franco. All rights reserved.
//

#import "MapViewModel.h"
#import "DatabaseManager.h"
#import "Deal.h"
#import "DealMapAnnotation.h"
#import "DrawerViewController.h"

@implementation MapViewModel

-(instancetype)init
{
    self = [super init];
    
    if(!self) return nil;
    
    return self;
    
}

-(CLLocationDistance)getRadius
{
    
    DatabaseManager* databaseManager = [DatabaseManager sharedDatabaseManager];
    
    NSDictionary* filter = [databaseManager managerGetUsersCurrentCriteria];
    
    NSInteger miles = [[filter valueForKey:NSLocalizedString(@"DISTANCE_FILTER", nil)] integerValue];
    
    double meters = (miles * 1609.34);
    
    CLLocationDistance radius = meters;
    
    return radius;
}

-(void)setUpdateEventsBtn:(UIButton *)btn
{
    [btn setBackgroundColor:[UIColor colorWithRed:(float)80/255 green:(float)141/255 blue:(float)234/255 alpha:(float)1]];
    
    btn.layer.cornerRadius = 5.0f;
    btn.layer.shadowOpacity = 0.7f;
    btn.layer.shadowOffset = CGSizeMake(5.0f, 10.0f);
    
}

-(void)setAnnotationCalloutView:(UIView *)annotationView
{
    [annotationView setAlpha:1.0];
    
    annotationView.layer.cornerRadius = 5.0f;
    
    annotationView.layer.shadowOpacity = 0.5f;
    
    annotationView.layer.shadowOffset = CGSizeMake(5.0f, 10.0f);
    
    annotationView.backgroundColor = [UIColor whiteColor];
}

@end
