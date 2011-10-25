//
//  SearchEngineYahoo.m
//  MiniBrowser
//
//  Created by Антон Помозов on 10.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "SearchEngineYahoo.h"

@implementation SearchEngineYahoo

@synthesize placeholder = _placeholder;

- (NSString *)placeholder
{
    if (!_placeholder) {
        _placeholder = @"Yahoo";
    }
    
    return _placeholder;
}

- (NSURL *)searchUrlForText:(NSString *)text
{
    self.searchUrl = @"http://search.yahoo.com/search?p=%@";
    NSString *readyUrl = [NSString stringWithFormat:self.searchUrl, text];
    readyUrl = [readyUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [NSURL URLWithString:readyUrl];
}

@end
