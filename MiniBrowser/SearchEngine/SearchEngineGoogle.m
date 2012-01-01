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
    NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.searchUrl = [@"http://www.google.com/search?ie=utf-8&oe=utf-8&q=" stringByAppendingString:encodedText];
    NSURL *theUrl = [NSURL URLWithString:self.searchUrl];
    
    return theUrl;
}

@end
