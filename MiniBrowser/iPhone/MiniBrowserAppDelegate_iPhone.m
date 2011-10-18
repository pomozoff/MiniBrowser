//
//  MiniBrowserAppDelegate_iPhone.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "MiniBrowserAppDelegate_iPhone.h"

@implementation MiniBrowserAppDelegate_iPhone

@synthesize nibName = _nibName;

- (NSString *)nibName
{
    _nibName = [super nibName];
    
    if (!_nibName) {
        _nibName = @"iPhoneBrowserView";
    }
    
    return _nibName;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.browserController.isIPad = NO;

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
