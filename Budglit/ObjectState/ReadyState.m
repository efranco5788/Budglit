//
//  ReadyState.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 7/28/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import "ReadyState.h"

@implementation ReadyState

-(instancetype)initState
{
    self = [super initState];
    
    if (![self isMemberOfClass:[ReadyState class]]) {        
        return nil;
    }
    
    return self;
}

@end
