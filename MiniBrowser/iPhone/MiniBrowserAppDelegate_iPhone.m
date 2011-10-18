//
//  MiniBrowserAppDelegate_iPhone.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "MiniBrowserAppDelegate_iPhone.h"

@interface MiniBrowserAppDelegate_iPhone()

@property (nonatomic, retain) UINavigationController *navigationController;

@end

@implementation MiniBrowserAppDelegate_iPhone

@synthesize nibName = _nibName;
@synthesize navigationController = _navigationController;

- (NSString *)nibName
{
    _nibName = [super nibName];
    
    if (!_nibName) {
        _nibName = @"iPhoneBrowserView";
    }
    
    return _nibName;
}

- (UINavigationController *)navigationController
{
    if (!_navigationController) {
        _navigationController = [[UINavigationController alloc] init];
        _navigationController.delegate = self.browserController;
    }
    
    return _navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.browserController.isIPad = NO;
    [self.navigationController pushViewController:self.browserController animated:NO];
    [self.window addSubview:self.navigationController.view];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)dealloc
{
    self.navigationController = nil;
    
    [super dealloc];
}

@end
