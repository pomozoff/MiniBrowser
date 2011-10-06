//
//  BrowserController.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BrowserController.h"

@interface BrowserController()

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end

@implementation BrowserController

@synthesize webView = _webView;
@synthesize navigationView = _navigationView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize urlField = _urlField;
@synthesize urlLabel = _urlLabel;

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    
    return _webView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)urlCallBack:(NSString *)sourceUrl navigationType:(UIWebViewNavigationType)navigationType
{
    /*
     UIWebViewNavigationType
     Constant indicating the user’s action.
     
     enum {
         UIWebViewNavigationTypeLinkClicked,
         UIWebViewNavigationTypeFormSubmitted,
         UIWebViewNavigationTypeBackForward,
         UIWebViewNavigationTypeReload,
         UIWebViewNavigationTypeFormResubmitted,
         UIWebViewNavigationTypeOther
     };
     typedef NSUInteger UIWebViewNavigationType;
     
     Constants
     
     UIWebViewNavigationTypeLinkClicked
         User tapped a link.
     UIWebViewNavigationTypeFormSubmitted
         User submitted a form.
     UIWebViewNavigationTypeBackForward
        User tapped the back or forward button.
     UIWebViewNavigationTypeReload
        User tapped the reload button.
     UIWebViewNavigationTypeFormResubmitted
        User resubmitted a form.
     UIWebViewNavigationTypeOther
        Some other action occurred.
    */
    
    return sourceUrl;
}

- (void)setButtonsStatus
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)backPressed:(id)sender
{
    [self.webView goBack];
    [self setButtonsStatus];
}

- (void)forwardPressed:(id)sender
{
    [self.webView goForward];
    [self setButtonsStatus];
}

- (NSString *)correctUrl:(NSString *)sourceUrl
{
    NSString *readyUrl;
    
    if ([sourceUrl hasPrefix:@"http://"])
        readyUrl = sourceUrl;
    else
        readyUrl = [NSString stringWithFormat:@"http://%@", sourceUrl];
    
    return readyUrl;
}

- (void)freeProperties
{
    self.webView = nil;
    self.navigationView = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.urlField = nil;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backButton addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(forwardPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    self.view.frame = CGRectOffset(self.view.frame, 0, statusBarRect.size.height);
    self.webView.frame = CGRectOffset([UIScreen mainScreen].bounds, 0, self.navigationView.bounds.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.backButton removeTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton removeTarget:self action:@selector(forwardPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self freeProperties];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *readyUrl = [self correctUrl:textField.text];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:readyUrl]]];
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.backButton.enabled = YES;
    self.forwardButton.enabled = NO;
    
    NSString *callBackString = [self urlCallBack:request.URL.absoluteString navigationType:navigationType];
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:callBackString]];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setButtonsStatus];
    self.urlLabel.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.urlLabel.text = @"Error";
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error loading url"
                                                    message:logString
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

@end
