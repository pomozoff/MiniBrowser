//
//  UIWebView+Extended.h
//  MiniBrowser
//
//  Created by Антон Помозов on 23.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Extended)

@property (nonatomic, assign) BOOL isThreaded;
@property (nonatomic, copy, readonly) NSString *webViewId;
@property (nonatomic, copy) NSString *currentUrl;
@property (nonatomic, retain) NSArray *history;

- (BOOL)canGoForwardExt;
- (BOOL)canGoBackExt;

- (void)goForwardExt;
- (void)goBackExt;

- (void)addURLToHistory:(NSString *)stringUrl;

@end
