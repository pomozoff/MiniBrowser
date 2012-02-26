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
#import "BrowserControllerProtocol.h"
#import "CallbackDelegate.h"

@interface TabPageData : NSObject <UIWebViewDelegate, PageHeaderInfo>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGSize pageViewSize;
@property (nonatomic, retain) UIImageView *previewImageView;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) id<UIWebViewDelegate, BrowserControllerDelegate> webViewDelegate;
@property (nonatomic, retain) id<CallbackDelegate> callbackDelegate;

// an example of using UINavigationController as the owner of the page. 
@property (nonatomic, retain) UINavigationController *navController; 

- (IBAction)closePage:(id)sender;

- (void)loadUrl;
- (void)loadUrl:(NSString *)url;
- (void)makeScreenShotOfTheView:(UIView *)view;

@end
