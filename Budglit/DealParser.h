//
//  DealParser.h
//  Budglit
//
//  Created by Emmanuel Franco on 8/1/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deal.h"

@interface DealParser : NSObject

typedef void(^parseCompletionBlock)(NSArray* parsedList);

-(id)initParser;

-(void)parseDeals:(NSArray*)list addCompletionHandler:(parseCompletionBlock)completionBlock;

@end
