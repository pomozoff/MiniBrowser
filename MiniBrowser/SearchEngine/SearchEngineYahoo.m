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

- (NSURL *)searchUrlForText:(NSString *)text
{
    self.searchUrl = @"http://search.yahoo.com/search?p=%@";
    NSString *readyUrl = [NSString stringWithFormat:self.searchUrl, text];
    //readyUrl = [readyUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [NSURL URLWithString:readyUrl];
}

@end
