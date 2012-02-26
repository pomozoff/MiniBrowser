//
//  SearchEngineGoogle.m
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "SearchEngineGoogle.h"

@implementation SearchEngineGoogle

@synthesize name = _name;

- (NSString *)name
{
    if (!_name) {
        _name = @"Google";
    }
    
    return _name;
}

- (NSString *)searchUrlForText:(NSString *)text
{
    NSString *searchUrl = [@"http://www.google.com/search?ie=utf-8&oe=utf-8&q=" stringByAppendingString:text];
    
    return searchUrl;
}

- (void)dealloc
{
    [_name release];
    _name = nil;
    
    [super dealloc];
}

@end
