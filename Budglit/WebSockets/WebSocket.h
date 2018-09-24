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
-(void)newDealAdded:(id)newDeal;
@end

@interface WebSocket : NSObject

@property (nonatomic, strong) SocketManager* socketManager;
@property (nonatomic, strong) SocketIOClient* socket;
@property (nonatomic, strong) id <WebSocketDelegate> delegate;

-(id)initWebSocketForDomain:(NSURL*)url withToken:(NSString*)token;

-(void)setSocketEventsShouldConnect:(BOOL)shouldConnect;

-(void)connectSocket;

@end

NS_ASSUME_NONNULL_END
