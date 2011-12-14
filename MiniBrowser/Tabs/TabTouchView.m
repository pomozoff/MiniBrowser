//
//  TabTouchView.m
//  MiniBrowser
//
//  Keeps UIView which should track taps.
//
//  Created by Антон Помозов on 07.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabTouchView.h"

@implementation TabTouchView

@synthesize receiver;

- (void)dealloc {
	self.receiver = nil;
    
    [super dealloc];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if ([self pointInside:point withEvent:event]) {
        return self.receiver;
	}

	return nil;
}

@end
