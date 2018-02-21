//
//  GeneralEventAnnotationView.m
//  Budglit
//
//  Created by Emmanuel Franco on 1/30/18.
//  Copyright © 2018 Emmanuel Franco. All rights reserved.
//

#import "GeneralEventAnnotationView.h"
#import "DealMapAnnotation.h"

static CGFloat kMaxViewWidth = 150.0;

static CGFloat kViewWidth = 90;
static CGFloat kViewLength = 100;

static CGFloat kLeftMargin = 30.0;
static CGFloat kRightMargin = 5.0;
static CGFloat kTopMargin = 5.0;

@implementation GeneralEventAnnotationView

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if(!self) return nil;
    
    DealMapAnnotation* mapItem = (DealMapAnnotation*)self.annotation;
    
    // offset the annotation so it won't obscure the actual lat/long location
    self.centerOffset = CGPointMake(50.0, 50.0);

    self.backgroundColor = [UIColor clearColor];
    
    self.animatesDrop = YES;
    
    //self.canShowCallout = YES;
    
    UILabel *annotationLabel = [self makeiOSLabel:mapItem.locationName];
    
    [self addSubview:annotationLabel];
    
    return self;
}

-(void)showCustomCallout
{
    if(self.showCustomCallOut)
    {
        
    }
}

-(void)setCustomCallout:(BOOL)shouldShowCallout
{
    self.showCustomCallOut = shouldShowCallout;
}

- (UILabel *)makeiOSLabel:(NSString *)placeLabel
{
    // add the annotation's label
    UILabel *annotationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    annotationLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    annotationLabel.textColor = [UIColor blackColor];
    annotationLabel.text = placeLabel;
    [annotationLabel sizeToFit];   // get the right vertical size
    
    // compute the optimum width of our annotation, based on the size of our annotation label
    CGFloat optimumWidth = annotationLabel.frame.size.width + kRightMargin + kLeftMargin;
    CGRect frame = self.frame;
    if (optimumWidth < kViewWidth)
        frame.size = CGSizeMake(kViewWidth, kViewLength);
    else if (optimumWidth > kMaxViewWidth)
        frame.size = CGSizeMake(kMaxViewWidth, kViewLength);
    else
        frame.size = CGSizeMake(optimumWidth, kViewLength);
    self.frame = frame;
    
    annotationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    annotationLabel.backgroundColor = [UIColor clearColor];
    CGRect newFrame = annotationLabel.frame;
    newFrame.origin.x = kLeftMargin;
    newFrame.origin.y = kTopMargin;
    newFrame.size.width = self.frame.size.width - kRightMargin - kLeftMargin;
    annotationLabel.frame = newFrame;
    
    return annotationLabel;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    // used to draw the pointer
    DealMapAnnotation* mapItem = (DealMapAnnotation*) self.annotation;
    
    if (mapItem != nil)
    {
        [[UIColor darkGrayColor] setFill];
        
        // draw the pointed shape
        UIBezierPath *pointShape = [UIBezierPath bezierPath];
        [pointShape moveToPoint:CGPointMake(14.0, 0.0)];
        [pointShape addLineToPoint:CGPointMake(0.0, 0.0)];
        [pointShape addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [pointShape fill];
        
    }
}
*/

@end
