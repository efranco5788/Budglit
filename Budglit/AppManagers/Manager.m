//
//  Manager.m
//  Budglit
//
//  Created by Emmanuel Franco on 7/18/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "Manager.h"


@implementation Manager

-(instancetype)init
{
    self = [self init];
    
    if(!self) return nil;
    
    return self;
}

-(instancetype)initWithEngineHostName:(NSString*)hostName
{
    self = [super init];
    
    if(hostName){
        
        NSString* newName = hostName.lowercaseString;
        
        [hostName isEqualToString:newName];
    }
    
    return self;
}

-(void)managerDisconnectWebSocket
{
    
}

-(void)managerContinousRetryRequest:(NSTimer*)timer
{

}

@end
