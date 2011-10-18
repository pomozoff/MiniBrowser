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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.browserController.isIPad = YES;
    [self.window addSubview:self.browserController.view];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
