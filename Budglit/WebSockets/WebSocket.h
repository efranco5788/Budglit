//
//  WebSocket.h
//  Budglit
//
//  Created by Emmanuel Franco on 9/22/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SocketIO;

NS_ASSUME_NONNULL_BEGIN

@protocol WebSocketDelegate <NSObject>
@optional

@end

@interface WebSocket : NSObject

@property (nonatomic, strong) SocketManager* socketManager;
@property (nonatomic, strong) SocketIOClient* socket;
@property (nonatomic, strong) id <WebSocketDelegate> delegate;

-(id)initWebSocketForStringDomain:(NSString*)urlString userToken:(NSString*)token;

-(id)initWebSocketForDomain:(NSURL*)url userToken:(NSString*)token;

-(void)connectSocket;

-(void)disconnect;

@end

NS_ASSUME_NONNULL_END
