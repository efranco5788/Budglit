//
//  Manager.h
//  Budglit
//
//  Created by Emmanuel Franco on 7/18/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Engine;

typedef void (^generalReturnBlockResponse)(id object);
typedef void (^generalCompletionHandler)(BOOL success);
typedef void (^fetchedImageResponse)(UIImage* image);
typedef void (^dataBlockResponse)(id response);
typedef void (^newDataFetchedResponse)(UIBackgroundFetchResult result);
typedef void (^addLocationResponse)(BOOL success);
typedef void (^fetchPostalCompletionHandler)(id object);

@interface Manager : NSObject

-(instancetype) init;

-(instancetype) initWithEngineHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;

-(void)managerContinousRetryRequest:(NSTimer*)timer;

-(void)managerDisconnectWebSocket;


@end
