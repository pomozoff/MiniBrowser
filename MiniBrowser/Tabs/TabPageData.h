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

@interface TabPageData : NSObject <PageHeaderInfo>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) TabPageView *view;

// an example of using UINavigationController as the owner of the page. 
@property (nonatomic, retain) UINavigationController *navController; 

@end
