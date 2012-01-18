//
//  PadPageView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "PadPageView.h"

@implementation PadPageView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result;
    
    if (CGRectContainsPoint(self.closeButton.frame, point)) {
        result = self.closeButton;
    } else {
        result = [super hitTest:point withEvent:event];
    }
    
    return result;
}

@end
