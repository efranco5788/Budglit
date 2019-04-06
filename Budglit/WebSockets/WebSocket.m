//
//  WebSocket.m
//  Budglit
//
//  Created by Emmanuel Franco on 9/22/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "WebSocket.h"
#import <stdlib.h>

#define LOG @"log"
#define COMPRESS @"compress"
#define CONNECT_PARAMS @"connectParams"
#define CONNECT @"connect"
#define RECONNECTS @"reconnects"
#define RECONNECT_ATTEMPTS @"reconnectAttempts"
#define RECONNECT_WAIT @"reconnectWait"
#define DEALS_UPDATED @"deals_updated"

@implementation WebSocket

-(id)initWebSocketForStringDomain:(NSString *)urlString userToken:(NSString*)token
{
    if(!urlString) return nil;
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    if(!url) return nil;
    else{
        self = [self initWebSocketForDomain:url userToken:token];
        
        return self;
    }
}

-(id)initWebSocketForDomain:(NSURL*)url userToken:(NSString*)token
{
    self = [super init];
    
    if(!self) return nil;
    
    if(!self.socketManager){
        
        self.socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{LOG: @YES, COMPRESS: @YES, CONNECT_PARAMS: token}];
        
        [self.socketManager setReconnects:YES];
        
        [self.socketManager setReconnectWait:10];
        
        self.socket = self.socketManager.defaultSocket;
        
    }
    
    return self;
    
}

-(void)connectSocket
{
    [self.socket connect];
}

-(void)disconnect
{
    [self.socket disconnect];
}

@end
