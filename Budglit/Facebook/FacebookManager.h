//
//  FacebookManager.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 11/29/16.
//  Copyright © 2016 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FacebookEngine;

@interface FacebookManager : NSObject

@property (nonatomic, strong) FacebookEngine* engine;

-(instancetype) initWithEngine NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, getter=isLoggedIn, readonly) BOOL loggedIn;

@end
