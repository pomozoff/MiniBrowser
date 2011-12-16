//
//  TabPageData.h
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageHeaderInfo.h"
#import "TabPageView.h"
#import "BrowserController.h"

@interface TabPageData : NSObject <NSCopying, PageHeaderInfo>

// an example of using UINavigationController as the owner of the page. 
@property (nonatomic, retain) UINavigationController *navController; 

- (id)copyWithZone:(NSZone *)zone;

@end
