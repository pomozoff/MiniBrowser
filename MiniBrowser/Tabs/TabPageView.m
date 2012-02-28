//
//  TabPageView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TabPageView.h"

@implementation TabPageView

@synthesize buttonNewTabView = _buttonNewTabView;
@synthesize closeButton = _closeButton;
@synthesize bottomView = _bottomView;
@synthesize addTabView = _addTabView;

@synthesize isNewTabButton = _isNewTabButton;
@synthesize isInitialized = _isInitialized;
@synthesize identityFrame = _identityFrame;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code        
        self.identityFrame = self.frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight
            | UIViewAutoresizingFlexibleLeftMargin
            | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleTopMargin
            | UIViewAutoresizingFlexibleBottomMargin;
        
         // set gradient for background view
         CAGradientLayer *glayer = [CAGradientLayer layer];
         glayer.frame = self.bounds;
         UIColor *topColor = [UIColor colorWithRed:0.57 green:0.63 blue:0.68 alpha:1.0];    // light blue-gray
         UIColor *bottomColor = [UIColor colorWithRed:0.31 green:0.41 blue:0.48 alpha:1.0]; // dark blue-gray
         glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
         [self.layer insertSublayer:glayer atIndex:0];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawShadowForPage:(TabPageView *)page
{
    // (use shadowPath to improve rendering performance)
	page.layer.shadowColor = [[UIColor blackColor] CGColor];	
	page.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	page.layer.shadowOpacity = 0.3f;
    page.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:page.bounds];
    page.layer.shadowPath = path.CGPath;	
}

- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    [self drawShadowForPage:self];
}

- (void)prepareForReuse;
{
	//reset modified properties
	self.transform = CGAffineTransformIdentity;
    
    UIView *imageView = [self viewWithTag:PREVIEW_IMAGE_TAG];
    [imageView removeFromSuperview];
}

@end
