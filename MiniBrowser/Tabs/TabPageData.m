//
//  TabPageData.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabPageData.h"

@implementation TabPageData

@synthesize webView = _webView;

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize navController = _navController;

@synthesize view = _view;

// ******************************************************************************************************************************

#pragma mark - PageScrollerHeaderInfo


- (NSString *)pageTitle
{
    return self.title;
}


- (NSString *)pageSubtitle
{
    return self.subtitle;
}

// ******************************************************************************************************************************

#pragma mark - NSObject 


- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ 0x%x: %@", [self class], self, self.title];
}

@end
