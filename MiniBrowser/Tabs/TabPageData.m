//
//  TabPageData.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabPageData.h"

@implementation TabPageData

//@synthesize webView = _webView;

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize navController = _navController;

//@synthesize pageView = _pageView;

// ******************************************************************************************************************************

#pragma mark - Properties initialization


- (NSString *)title
{
    if (!_title) {
        _title = @"Untitled";
    }
    
    return _title;
}

- (NSString *)subtitle
{
    if (!_subtitle) {
        _subtitle = @"";
    }
    
    return _subtitle;
}

// ******************************************************************************************************************************

#pragma mark - NSObject 


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ 0x%x: %@", [self class], self, self.title];
}

// ******************************************************************************************************************************

#pragma mark - NSCopying 


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
