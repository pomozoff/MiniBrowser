//
//  SearchEngineYahoo.m
//  MiniBrowser
//
//  Created by Антон Помозов on 10.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "SearchEngineYahoo.h"

@implementation SearchEngineYahoo

@synthesize name = _name;

- (NSString *)name
{
    if (!_name) {
        _name = @"Yahoo";
    }
    
    return _name;
}

- (NSString *)searchUrlForText:(NSString *)text
{
    NSString *searchUrl = [@"http://search.yahoo.com/search?p=" stringByAppendingString:text];
    
    return searchUrl;
}

- (void)dealloc
{
    [_name release];
    _name = nil;
    
    [super dealloc];
}

@end
