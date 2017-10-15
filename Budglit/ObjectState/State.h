//
//  State.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 7/26/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface State : NSObject

-(instancetype)initState NS_DESIGNATED_INITIALIZER;

-(void) disableInterface:(id)sender;

-(void) enableInterface:(id)sender;


@end
