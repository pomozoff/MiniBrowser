//
//  TabPageData.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TabPageData.h"
#import "UIWebView+Extended.h"

@implementation TabPageData

@synthesize pageViewSize = _pageViewSize;
@synthesize previewImageView = _previewImage;
@synthesize webView = _webView;
@synthesize webViewDelegate = _webViewDelegate;

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize navController = _navController;

//@synthesize pageView = _pageView;

// ******************************************************************************************************************************

#pragma mark - Properties initialization


- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.isThreaded = NO;
    }
    
    return _webView;
}

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

- (void)dealloc
{
    self.previewImageView = nil;
    self.webView = nil;
    self.webViewDelegate = nil;
    
    self.title = nil;
    self.subtitle = nil;
    self.navController = nil;
    
    [super dealloc];
}

// ******************************************************************************************************************************

#pragma mark - WebView Delegate


- (void)setLabel:(NSString *)label andUrl:(NSString *)url
{
    self.title = label;
    self.subtitle = url;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (result) {
        [self setLabel:@"Loading" andUrl:request.URL.absoluteString];
    }
    
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *label = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *sourceUrl = webView.request.URL.absoluteString;
    
    [self setLabel:label andUrl:sourceUrl];
    [self.webViewDelegate webViewDidFinishLoad:webView];

    if (CGSizeEqualToSize(webView.frame.size, CGSizeZero)) {
        CGRect frame = webView.frame;
        frame.size = self.pageViewSize;
        webView.frame = frame;
    }
    
    // make screenshot loaded page
    [self makeScreenShotFromTheView:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSString *sourceUrl = webView.request.URL.absoluteString;
    
    [self setLabel:logString andUrl:sourceUrl];
    [self.webViewDelegate webView:webView didFailLoadWithError:error];
    
    // make screenshot loaded page
    [self makeScreenShotFromTheView:webView];
}

// ******************************************************************************************************************************

#pragma mark - Page Data Delegate


- (void)loadUrl
{
    [self loadUrl:self.subtitle];
}

- (void)loadUrl:(NSString *)url
{
    NSString *trimmedUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isUrlEmpty = !trimmedUrl || [trimmedUrl isEqualToString:@""];

    if (isUrlEmpty) {
        return;
    }
    
    NSString *readyUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlObject = [NSURL URLWithString:readyUrl];
    
    if (!urlObject.scheme) {
        urlObject = [NSURL URLWithString:[@"http://" stringByAppendingString:urlObject.absoluteString]];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlObject]];
}

- (void)makeScreenShotFromTheView:(UIView *)view
{
    if (CGSizeEqualToSize(view.frame.size, CGSizeZero)) {
        return;
    }
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(self.pageViewSize, NO, 0);
    else
        UIGraphicsBeginImageContext(self.pageViewSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // remember imageview
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.previewImageView = imageView;
    self.previewImageView.tag = 100;
    [imageView release];
    
    // replace new screenshot
    [self.previewImageView removeFromSuperview];
    [self.webViewDelegate placeScreenshotOnPageViewFromPageData:self];
}

@end
