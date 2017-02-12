//
//  DatabaseEngine.h
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "Engine.h"

@class ImageData;
@class AppDelegate;

typedef void (^fetchedDataResponse)(UIImage* imageResponse, NSHTTPURLResponse* response, NSURLRequest* request);
typedef void (^operationCancelResponse)(BOOL success);

@protocol DatabaseEngineDelegate <NSObject>
-(void)totalDealCountReturned:(NSInteger)responseCount;
-(void)totalDealCountFailedWithError:(NSError*)error;
-(void)dealsReturned:(NSDictionary*)deals;
-(void)dealsFailedWithError:(NSError*)error;
-(void)operationsCancelled;
@optional

@end

@interface DatabaseEngine : Engine

@property (nonatomic, strong) id <DatabaseEngineDelegate> delegate;

-(id)init;

-(id)initWithHostName:(NSString*)hostName;

-(void) sendSearchCriteriaForTotalCountOnly:(NSDictionary*)searchCriteria;

-(void) sendSearchCriteria:(NSDictionary*)searchCriteria;

-(void) downloadImageFromURL:(NSString*)urlString forImageView:(UIImageView*)imageView addCompletionHandler:(fetchedDataResponse)completionHandler;

-(void) downloadImageFromRequest:(NSURLRequest*)request addCompletionHandler:(fetchedDataResponse)completionHandler;

-(void) cancelOperations:(operationCancelResponse)completionHandler;

@end
