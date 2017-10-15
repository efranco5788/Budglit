//
//  DatabaseEngine.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 9/26/15.
//  Copyright © 2015 Emmanuel Franco. All rights reserved.
//

#import "DatabaseEngine.h"
#import "AppDelegate.h"
#import "ImageData.h"
#import "UIImage+Resizing.h"
#import "UIImageView+AFNetworking.h"

#define SEARCH_DEALS @"search"
#define TEMP_SEARCH_RESULTS @"tempsearch"
#define HTTP_POST_METHOD @"POST"
#define KEY_EMPTY_VALUES @"emptyValues"
#define KEY_ERROR @"error"
#define KEY_DEALS @"allDeals"
#define KEY_LIST @"parsedList"
#define DEAL_COUNT @"count"

#define RESCALE_IMAGE_WIDTH 1024
#define RESCALE_IMAGE_HEIGHT 1024

@implementation DatabaseEngine

-(instancetype) init
{
    return [self initWithHostName:nil];
}

-(instancetype) initWithHostName:(NSString*)hostName
{
    
    self = [super initWithHostName:hostName];
    
    if (!self) {
        return nil;
    }
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}

-(void)sendSearchCriteriaForTotalCountOnly:(NSDictionary *)searchCriteria
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

    //AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //[policy setValidatesDomainName:NO];
    
    //[policy setAllowInvalidCertificates:YES];
    
    //[self.sessionManager setSecurityPolicy:policy];
    
    [self.sessionManager POST:TEMP_SEARCH_RESULTS parameters:searchCriteria progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if (responseObject) {
            
            BOOL isEmpty = [[responseObject valueForKey:KEY_EMPTY_VALUES] boolValue];
            
            if (isEmpty) {
                
                NSString* errorMessage = [responseObject valueForKey:KEY_ERROR];
                
                NSLog(@"%@", errorMessage);
            }
            else{
                
                NSArray* list = [responseObject valueForKey:KEY_LIST];
                
                NSDictionary* obj = list[0];
                
                NSInteger total = [[obj valueForKey:DEAL_COUNT] integerValue];
                
                [self.delegate totalDealCountReturned:total];
                
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        
        [self logFailedRequest:task];
        
        [self.delegate dealsFailedWithError:error];
        
    }];

}

-(void)sendSearchCriteria:(NSDictionary *)searchCriteria
{
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self.sessionManager POST:SEARCH_DEALS parameters:searchCriteria progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self addToRequestHistory:task];
        
        if (responseObject) {
            
            
            NSArray* dict = [responseObject valueForKey:KEY_LIST];
            
            NSDictionary* obj = dict[0];
            
            NSInteger total = [[obj valueForKey:DEAL_COUNT] integerValue];
            
            if (total <= 0) {
                
                NSString* errorMessage = [responseObject valueForKey:KEY_ERROR];
                
                NSLog(@"%@", errorMessage);
            }
            else{
                
                NSArray* deals = [responseObject valueForKey:@"deals"];
                
                NSLog(@"%@", deals);
                
                [self.delegate dealsReturned:deals];
                
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self logFailedRequest:task];
        
        [self.delegate dealsFailedWithError:error];
        
    }];
    
}

-(void)downloadImageFromURL:(NSString *)urlString forImageView:(UIImageView *)imageView addCompletionHandler:(fetchedDataResponse)completionHandler{
    
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"fetching image %@", imageRequest.URL);
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        NSLog(@"Image fetched %@", response);
        
        completionHandler(image, response, request);
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        
        if (response.statusCode == 404) {
            
            NSLog(@"Image fetched %@", error);
            
            completionHandler(nil, response, request);
            
        }
        
    }];
    
}

-(void)downloadImageFromRequest:(NSURLRequest *)request addCompletionHandler:(fetchedDataResponse)completionHandler
{
    UIImageView* imgView = [[UIImageView alloc] init];
    
    [imgView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        NSLog(@"Image fetched %@", response);
        
        
        completionHandler(image, response, request);
        
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}

-(void)cancelOperations:(generalBlockResponse)completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.sessionManager.operationQueue cancelAllOperations];
        
        [self.sessionManager.operationQueue waitUntilAllOperationsAreFinished];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            NSLog(@"Done canceling");
            
            completionHandler(YES);
            
        });
        
    });
    
    //[self.requestManager.operationQueue cancelAllOperations];
    
    [self.sessionManager.operationQueue cancelAllOperations];
    
    [self.delegate operationsCancelled];
}

@end
