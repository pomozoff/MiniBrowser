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

- (SearchEngine *)currentSearchEngine
{
    if (!_currentSearchEngine) {
        _currentSearchEngine = [[SearchEngineYahoo alloc] init];
    }
    
    return _currentSearchEngine;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    self.currentSearchEngine = nil;
    
    [super dealloc];
}

@end
