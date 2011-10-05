//
//  MiniBrowserAppDelegate_iPad.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "MiniBrowserAppDelegate_iPad.h"

@implementation MiniBrowserAppDelegate_iPad

@synthesize nibName = _nibName;

- (NSString *)nibName
{
    _nibName = [super nibName];
    
    if (!_nibName) {
        _nibName = @"iPadBrowserView";
    }
    
    return _nibName;
}

@end
