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

-(id) initWithEngine;

-(BOOL) isLoggedIn;

@end
