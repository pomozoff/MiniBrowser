//
//  SettingsController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "SettingsController.h"
#import "SearchEngineGoogle.h"
#import "SearchEngineYahoo.h"

@implementation SettingsController

@synthesize currentSearchEngine = _currentSearchEngine;

NSString *const settingSearchEngine = @"setting_search_engine";

- (SearchEngine *)currentSearchEngine
{
    /*
    if (_currentSearchEngine) {
        if (![searchEngine isEqualToString:self.currentSearchEngine.name]) {
            [_currentSearchEngine release];
            _currentSearchEngine = nil;
        }
    }
    */
    
    if (!_currentSearchEngine) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        NSString *searchEngine = [defaults objectForKey:settingSearchEngine];
        
        if ([searchEngine isEqualToString:@"Yahoo"]) {
            _currentSearchEngine = [[SearchEngineYahoo alloc] init];
        } else {
            _currentSearchEngine = [[SearchEngineGoogle alloc] init];
        }
    }
    
    return _currentSearchEngine;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(loadSettings)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];
    }
    
    return self;
}

- (void)loadSettings
{
    self.currentSearchEngine = nil;
}

- (void)dealloc
{
    self.currentSearchEngine = nil;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self 
                      name:UIApplicationWillEnterForegroundNotification 
                    object:nil];

    [super dealloc];
}

@end
