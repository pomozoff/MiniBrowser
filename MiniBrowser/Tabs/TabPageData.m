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

@synthesize index = _index;
@synthesize pageViewSize = _pageViewSize;
@synthesize previewImageView = _previewImageView;
@synthesize webView = _webView;
@synthesize webViewDelegate = _webViewDelegate;
@synthesize callbackDelegate = _callbackDelegate;

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize navController = _navController;

NSString *const requestMarker = @"123";

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
        _webView.allowsInlineMediaPlayback = YES;
        _webView.backgroundColor = [UIColor greenColor];
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

#pragma mark - Page Data Delegate


- (void)makeScreenShotOfTheView:(UIView *)view
{
    if (CGSizeEqualToSize(view.frame.size, CGSizeZero)) {
        return;
    }
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(self.pageViewSize, NO, 0);
    else
        UIGraphicsBeginImageContext(self.pageViewSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        UIGraphicsEndImageContext();
        return;
    }
    
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // remove old view from superview
    [self.previewImageView removeFromSuperview];
    
    // remember imageview
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    self.previewImageView = imageView;
    self.previewImageView.tag = PREVIEW_IMAGE_TAG;
    [imageView release];
    
    // replace new screenshot
    [self.webViewDelegate placeScreenshotOnPageViewFromPageData:self];
}

- (void)loadUrl:(NSString *)url withRequest:(NSURLRequest *)request
{
    NSString *trimmedUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!trimmedUrl || [trimmedUrl isEqualToString:@""]) {
        return;
    }
    
    NSString *modUrl = [self.callbackDelegate urlCallBack:trimmedUrl navigationType:UIWebViewNavigationTypeOther];
    NSURL *urlObject = [NSURL URLWithString:modUrl];
    
    if (!urlObject.scheme) {
        urlObject = [NSURL URLWithString:[@"http://" stringByAppendingString:urlObject.absoluteString]];
    }
    
    //NSMutableURLRequest *modRequest = [NSMutableURLRequest requestWithURL:urlObject];
    NSMutableURLRequest *modRequest;
    if (request) {
        modRequest = [request mutableCopy];
        modRequest.URL = urlObject;
    } else {
        modRequest = [NSMutableURLRequest requestWithURL:urlObject];
    }
    
    [modRequest addValue:requestMarker forHTTPHeaderField:requestMarker];
    NSURLRequest *readyRequest = modRequest;
    
    [self.webView loadRequest:readyRequest];
}

- (void)loadUrl:(NSString *)url
{
    [self loadUrl:url withRequest:nil];
}
     
- (void)loadUrl
{
    [self loadUrl:self.subtitle];
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
    if ([request.URL.absoluteString isEqualToString:request.mainDocumentURL.absoluteString]) {
        NSString *value = [request valueForHTTPHeaderField:requestMarker];
        if (![value isEqualToString:requestMarker]) {
            NSString *sourceUrl = request.URL.absoluteString;
            [self loadUrl:sourceUrl withRequest:request];
            
            return NO;
        }
    }

    BOOL result = [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (result) {
        [self setLabel:@"Loading" andUrl:request.URL.absoluteString];
    }

    if (CGSizeEqualToSize(webView.frame.size, CGSizeZero)) {
        CGRect frame = webView.frame;
        frame.size = self.pageViewSize;
        webView.frame = frame;
    }

    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *label = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *sourceUrl = webView.request.URL.absoluteString;
    
    if (![webView.currentUrl isEqualToString:webView.request.URL.absoluteString]) {
        if ([webView.request.URL.absoluteString isEqualToString:webView.request.mainDocumentURL.absoluteString]) {
            [self setLabel:label andUrl:sourceUrl];
        }
    }
    
    [self.webViewDelegate webViewDidFinishLoad:webView];
    
    // make screenshot loaded page
    [self makeScreenShotOfTheView:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSString *sourceUrl = webView.request.URL.absoluteString;

    if (![webView.currentUrl isEqualToString:webView.request.URL.absoluteString]) {
        if ([webView.request.URL.absoluteString isEqualToString:webView.request.mainDocumentURL.absoluteString]) {
            [self setLabel:logString andUrl:sourceUrl];
        }
    }
    
    [self.webViewDelegate webView:webView didFailLoadWithError:error];
    
    // make screenshot loaded page
    //[self makeScreenShotOfTheView:webView];
}

// ******************************************************************************************************************************

#pragma mark - Page Data Actions


- (IBAction)closePage:(id)sender
{
    [self.webViewDelegate closePageAtIndex:self.index];
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

@end
