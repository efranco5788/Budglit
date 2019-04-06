//
//  DealViewModel.h
//  Budglit
//
//  Created by Emmanuel Franco on 9/25/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Deal;

NS_ASSUME_NONNULL_BEGIN

@interface DealViewModel : NSObject

@property (strong, nonatomic) Deal* deal;
@property (strong, nonatomic) NSString* venueName;
@property (strong, nonatomic) NSString* descriptionText;
@property (strong, nonatomic) NSString* distanceText;
@property (strong, nonatomic) NSString* budgetText;
@property (strong, nonatomic) NSString* addressText;
@property (strong, nonatomic) NSString* phoneText;
@property (strong, nonatomic) UIImage* image;

-(instancetype)initWithDeal:(Deal*)aDeal;

@end

NS_ASSUME_NONNULL_END
