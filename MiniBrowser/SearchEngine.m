//
//  SearchEngine.m
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "SearchEngine.h"

@implementation SearchEngine

@synthesize name = _name;
@synthesize searchUrl = _searchUrl;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSURL *)searchUrlForText:(NSString *)text
{
    return nil;
}

- (void)dealloc
{
    if (_name) {
        [_name release];
        _name = nil;
    }
    
    self.searchUrl = nil;
    
    [super dealloc];
}

@end
