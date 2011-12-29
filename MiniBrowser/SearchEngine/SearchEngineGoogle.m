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

- (NSURL *)searchUrlForText:(NSString *)text
{
    self.searchUrl = @"http://www.google.com/search?q=%@&ie=utf-8&oe=utf-8";
    NSString *readyUrl = [NSString stringWithFormat:self.searchUrl, text];
    readyUrl = [readyUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       
    return [NSURL URLWithString:readyUrl];
}

@end
