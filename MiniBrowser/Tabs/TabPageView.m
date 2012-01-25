//
//  TabPageView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabPageView.h"

@implementation TabPageView

@synthesize buttonNewTabView = _buttonNewTabView;
@synthesize closeButton = _closeButton;
@synthesize bottomView = _bottomView;

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
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
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

- (void)prepareForReuse;
{
	//reset modified properties
	self.transform = CGAffineTransformIdentity;
    
    UIView *imageView = [self viewWithTag:PREVIEW_IMAGE_TAG];
    [imageView removeFromSuperview];
}

@end
