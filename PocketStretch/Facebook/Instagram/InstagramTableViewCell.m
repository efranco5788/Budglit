//
//  InstagramTableViewCell.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 1/11/17.
//  Copyright © 2017 Emmanuel Franco. All rights reserved.
//

#import "InstagramTableViewCell.h"

@interface InstagramTableViewCell()
@property (nonatomic, strong) InstagramObject* object;
@end

@implementation InstagramTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configure
{
    if (!self.activityIndicator) {
        
        CGRect insetFrame = CGRectInset(self.bounds, 2.0, 2.0);
        CGRect offsetFrame = CGRectOffset(insetFrame, self.frame.size.width, self.frame.size.height);
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:offsetFrame];
        
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:self.activityIndicator];
    }
    
    [self.activityIndicator stopAnimating];
    
    if (!self.webView) {
        self.webView = [[UIWebView alloc] init];
        
        [self.webView.scrollView setScrollEnabled:NO];
        
        [self.webView setDelegate:self];
        
        CGRect frameSize = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        [self.webView setFrame:frameSize];
    }
    
}

-(void)beginLoadingReuqest:(InstagramObject *)obj
{
    if (!self.object) {
        self.object = obj;
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:obj.link];
    
    if (request) {
        [self.webView loadRequest:request];
    }
}

-(void)displayInstagramView
{
    [self addSubview:self.webView];
}

#pragma mark -
#pragma mark - Web View Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate webViewLoadedForObject:self.object];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
