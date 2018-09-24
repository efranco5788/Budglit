//
//  WebSocket.m
//  Budglit
//
//  Created by Emmanuel Franco on 9/22/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "WebSocket.h"

#define LOG @"log"
#define COMPRESS @"compress"
#define CONNECT_PARAMS @"connectParams"
#define CONNECT @"connect"
#define DEALS_UPDATED @"deals_updated"

@implementation WebSocket

-(id)initWebSocketForDomain:(NSURL*)url withToken:(NSString *)token
{
    self = [super init];
    
    if(!self) return nil;
    
    if(!self.socketManager){

        self.socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{LOG: @YES, COMPRESS: @YES, CONNECT_PARAMS: token}];
        
        self.socket = self.socketManager.defaultSocket;
    }
    
    return self;
    
}

-(void)setSocketEventsShouldConnect:(BOOL)shouldConnect
{
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];
    
    [self.socket on:@"deals_updated" callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        [self.delegate newDealAdded:data];
        
    }];
    
    
    if(shouldConnect) [self connectSocket];
}

-(void)connectSocket
{
    [self.socket connect];
}

@end
