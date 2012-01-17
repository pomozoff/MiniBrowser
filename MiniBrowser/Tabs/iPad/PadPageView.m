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
    CGRect preparedPageFrame = self.identityFrame;
    preparedPageFrame.origin.x = 0;
    preparedPageFrame.origin.y = 0;
    
    if (CGRectContainsPoint(self.closeButton.frame, point)) {
        return self.closeButton;
    } else if (CGRectContainsPoint(preparedPageFrame, point)) {
        return self;
    }
    
    return nil;
}

@end
