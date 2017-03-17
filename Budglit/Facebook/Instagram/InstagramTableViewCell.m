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
        
        [self.contentView addSubview:self.activityIndicator];
    }
    
    [self.activityIndicator stopAnimating];
    
    /*
    if (!self.avPlayer) {
        NSURL* url = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
        self.avPlayer = [[AVPlayer alloc] initWithURL:url];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        [self.avPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
        
        CGRect parentViewSize = self.contentView.frame;
        CGRect frameSize = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
        [self.playerLayer setFrame:frameSize];
        [self.playerLayer setBackgroundColor:[[UIColor greenColor] CGColor]];
        [self.layer addSublayer:self.playerLayer];
    }
    */
    
    /*
    if (!self.webView) {
        self.webView = [[UIWebView alloc] init];
        
        [self.webView.scrollView setScrollEnabled:NO];
        
        self.webView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.webView setDelegate:self];
        
        CGRect parentViewSize = self.contentView.frame;
        
        CGRect frameSize = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
        
        [self.webView setFrame:frameSize];
    }
    */
    
}


-(void)beginLoadingReuqest:(InstagramObject *)obj
{
    
    if (!self.object) {
        self.object = obj;
    }
    /*
    NSURLRequest* request = [NSURLRequest requestWithURL:obj.link];
    
    if (request) {
        [self.webView loadRequest:request];
    }
     */
    
    /*
    
    CGRect parentViewSize = self.contentView.frame;
    CGRect frameSize = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, parentViewSize.size.width, parentViewSize.size.height);
    [self.object.playerLayer setFrame:frameSize];
    [self.object.playerLayer setBackgroundColor:[[UIColor greenColor] CGColor]];
    [self.layer addSublayer:self.object.playerLayer];
    
    [self.object.avPlayer play];
    [self.delegate loadedForObject:self.object];
     
    */
}

-(void)cellDidDisappear
{
    [self.object.avPlayer pause];
}

@end
