//
//  PadPageView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "PadPageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PadPageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code        
        // set gradient for background view
        CAGradientLayer *glayer = [CAGradientLayer layer];
        glayer.frame = self.addTabView.bounds;
        UIColor *topColor = [UIColor colorWithRed:0.57 green:0.63 blue:0.68 alpha:1.0];    // light blue-gray
        UIColor *bottomColor = [UIColor colorWithRed:0.31 green:0.41 blue:0.48 alpha:1.0]; // dark blue-gray
        glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
        [self.addTabView.layer insertSublayer:glayer atIndex:0];
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result;
    
    if ([self.subviews containsObject:self.closeButton] && self.closeButton.alpha > 0.5f && CGRectContainsPoint(self.closeButton.frame, point)) {
        result = self.closeButton;
    } else {
        result = [super hitTest:point withEvent:event];
    }
    
    return result;
}

@end
