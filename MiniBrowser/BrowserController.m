//
//  BrowserController.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BrowserController.h"
#import "SettingsController.h"
#import "SearchEngine.h"
#import "BookmarksTableViewController.h"
#import "BookmarksStorageProtocol.h"
#import "BookmarkSaveTableViewController.h"
#import "BookmarksStorage.h"

@interface BrowserController()

@property (nonatomic, retain) SettingsController *settingsController;
@property (nonatomic, retain) SearchEngine *searchEngine;
@property (nonatomic, retain) BookmarksTableViewController *bookmarksTableViewController;
@property (nonatomic, retain) BookmarkSaveTableViewController *bookmarkSaveTableViewController;
@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;
@property (nonatomic, retain) UIPopoverController *popoverBookmark;
@property (nonatomic, retain) UIPopoverController *popoverSaveBookmark;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UINavigationController *bookmarkNavigationController;

@end

@implementation BrowserController

@synthesize isIPad = _isIPad;

@synthesize navigationBar = _navigationBar;
@synthesize navigationToolbar = _navigationView;
@synthesize searchBar = _searchBar;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize bookmarkButton = _bookmarkButton;
@synthesize actionButton = _actionButton;
@synthesize urlField = _urlField;
@synthesize urlLabel = _urlLabel;
@synthesize webView = _webView;

@synthesize settingsController = _settingsController;
@synthesize searchEngine = _searchEngine;
@synthesize bookmarksTableViewController = _bookmarksTableViewController;
@synthesize bookmarkSaveTableViewController = _bookmarkSaveTableViewController;
@synthesize bookmarksStorage = _bookmarksStorage;
@synthesize popoverBookmark = _popoverBookmark;
@synthesize popoverSaveBookmark = _popoverSaveBookmark;
@synthesize actionSheet = _actionSheet;
@synthesize bookmarkNavigationController = _bookmarkNavigationController;

BOOL userInitiatedJump = NO;
NSString *const savedUrlKey = @"savedCurrentUrl";

- (SettingsController *)settingsController
{
    if (!_settingsController) {
        _settingsController = [[SettingsController alloc] init];
    }
    
    return _settingsController;
}

- (SearchEngine *)searchEngine
{
    if (!_searchEngine) {
        _searchEngine = [self.settingsController currentSearchEngine];
    }
    
    return _searchEngine;
}

- (id <BookmarksStorageProtocol>)bookmarksStorage
{
    if (!_bookmarksStorage) {
        _bookmarksStorage = [[BookmarksStorage alloc] init];
    }
    
    return _bookmarksStorage;
}

- (BookmarksTableViewController *)bookmarksTableViewController
{
    if (!_bookmarksTableViewController) {
        _bookmarksTableViewController = [[BookmarksTableViewController alloc] init];
        _bookmarksTableViewController.delegateController = self;
        _bookmarksTableViewController.bookmarksStorage = self.bookmarksStorage;
    }
    
    return _bookmarksTableViewController;
}

- (BookmarkSaveTableViewController *)bookmarkSaveTableViewController
{
    if (!_bookmarkSaveTableViewController) {
        _bookmarkSaveTableViewController = [[BookmarkSaveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        _bookmarkSaveTableViewController.bookmarksStorage = self.bookmarksStorage;
    }
    
    return _bookmarkSaveTableViewController;
}

- (UIActionSheet *)actionSheet
{
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Add bookmark", nil];
    }
    
    return _actionSheet;
}

- (UINavigationController *)bookmarkNavigationController
{
    if (!_bookmarkNavigationController) {
        _bookmarkNavigationController = [[UINavigationController alloc] init];
        [_bookmarkNavigationController pushViewController:self.bookmarksTableViewController animated:NO];
    }
    
    return _bookmarkNavigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)saveCurrentPage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.urlField.text forKey:savedUrlKey];
    [defaults synchronize];
}

- (void)saveBookmarks
{
    [self saveCurrentPage];
    [self.bookmarksStorage saveBookmarks];
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
    
    NSString *outUrl = [NSString stringWithFormat:@"%@", sourceUrl];
//    NSString *outUrl = @"http://www.google.com/";
    
    return outUrl;
}

- (void)setButtonsStatus
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

/*
- (void)cancelSavingBookmark:(UIBarButtonItem *)sender
{
    [self.popoverSaveBookmark dismissPopoverAnimated:YES];
    self.popoverSaveBookmark = nil;
}
*/

- (void)dismissOpenPopoversAndActionSheet
{
    if ([self.popoverBookmark isPopoverVisible]) {
        [self.popoverBookmark dismissPopoverAnimated:NO];
        self.popoverBookmark = nil;
    }
    
    if ([self.popoverSaveBookmark isPopoverVisible]) {
        [self.popoverSaveBookmark dismissPopoverAnimated:YES];
        self.popoverSaveBookmark = nil;
        self.bookmarkSaveTableViewController = nil;
    }
    
    if ([self.actionSheet isVisible]) {
        [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:YES];
        self.actionSheet = nil;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)finishEditing
{
    [self.urlField resignFirstResponder];
    [self.searchBar resignFirstResponder];
}

- (IBAction)backPressed:(id)sender
{
    [self.webView goBack];
}

- (IBAction)forwardPressed:(id)sender
{
    [self.webView goForward];
}

- (void)displaySaveNewBookmarkPopoverForBarButton:(UIBarButtonItem *)barItem
{
    [self dismissOpenPopoversAndActionSheet];
    
    self.bookmarkSaveTableViewController.title = barItem.title;
    
    BookmarkItem *currentFolder = self.bookmarksStorage.rootFolder;

    BookmarksTableViewController *bookmarkTVC = nil;
    UIViewController *topViewController = self.bookmarkNavigationController.topViewController;
    if ([topViewController isKindOfClass:[BookmarksTableViewController class]]) {
        bookmarkTVC = (BookmarksTableViewController *)topViewController;
        currentFolder = [bookmarkTVC.currentFolder isEqualToBookmark:self.bookmarksStorage.historyFolder] ? 
                                self.bookmarksStorage.rootFolder : bookmarkTVC.currentFolder;
    }
    
    BookmarkItem *newBookmark = [[BookmarkItem alloc] initWithName:self.urlLabel.text
                                                               url:self.urlField.text
                                                              date:[NSDate date]
                                                             folder:NO
                                                         permanent:NO];
    self.bookmarkSaveTableViewController.bookmark = newBookmark;
    self.bookmarkSaveTableViewController.currentFolder = [currentFolder isEqualToBookmark:self.bookmarksStorage.historyFolder] ?
                                                         self.bookmarksStorage.rootFolder : currentFolder;
    
    newBookmark.delegateController = bookmarkTVC ? bookmarkTVC : self.bookmarksTableViewController;
    [newBookmark release];

    if (self.isIPad) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];

        [navigationController pushViewController:self.bookmarkSaveTableViewController animated:NO];
        self.popoverSaveBookmark = popover;
        
        [popover release];
        [navigationController release];

        self.bookmarkSaveTableViewController.delegateController = self;
        self.popoverSaveBookmark.delegate = self;
        
        [self.popoverSaveBookmark presentPopoverFromBarButtonItem:barItem
                                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                                         animated:YES];
    } else {
        [self.navigationController pushViewController:self.bookmarkSaveTableViewController animated:YES];
    }
}

- (IBAction)bookmarkPressed:(id)sender
{
    [self dismissOpenPopoversAndActionSheet];
    [self finishEditing];
    
    if (self.isIPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.bookmarkNavigationController];
        
        self.popoverBookmark = popover;
        self.popoverBookmark.delegate = self;
        
        [popover release];
        
        [self.popoverBookmark presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController pushViewController:self.bookmarksTableViewController animated:YES];
    }
}

- (IBAction)actionPressed:(id)sender
{
    [self dismissOpenPopoversAndActionSheet];
    [self finishEditing];
    
    [self.actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.actionSheet) {
        switch (buttonIndex) {
            case 0: { // Add bookmark button
                [self displaySaveNewBookmarkPopoverForBarButton:self.actionButton];
                break;
            }
            
            default:
                break;
        }
    }
}

- (void)freeProperties
{
    self.navigationBar = nil;
    self.navigationToolbar = nil;
    self.searchBar = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.bookmarkButton = nil;
    self.urlField = nil;
    self.urlLabel = nil;
    self.webView = nil;
    
    self.settingsController = nil;
    self.searchEngine = nil;
    self.bookmarksTableViewController = nil;
    self.bookmarkSaveTableViewController = nil;
    self.bookmarksStorage = nil;
    self.popoverBookmark = nil;
    self.actionSheet = nil;
    self.bookmarkNavigationController = nil;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)loadUrl:(NSString *)url
{
    if (!url) {
        return;
    }
    
    NSString *trimmedUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedUrl isEqualToString:@""]) {
        url = self.urlField.text;
    }
    
    //NSString *readyUrl = [self correctUrl:url];
    NSString *readyUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlObject = [NSURL URLWithString:readyUrl];
    
    if (!urlObject.scheme) {
        urlObject = [NSURL URLWithString:[@"http://" stringByAppendingString:urlObject.absoluteString]];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlObject]];
}

- (void)closePopupsAndLoadUrl:(NSString *)url
{
    userInitiatedJump = YES;
    [self dismissOpenPopoversAndActionSheet];
    [self loadUrl:url];
}

- (void)restoreOpenedUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *savedUrl = [defaults objectForKey:savedUrlKey];
    [self closePopupsAndLoadUrl:savedUrl];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setButtonsStatus];
    self.searchBar.placeholder = self.searchEngine.placeholder;
    
    [self restoreOpenedUrl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.view.frame = CGRectOffset(self.view.frame, 0, statusBarHeight);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self freeProperties];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

# pragma mark - web view cnotroller delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (userInitiatedJump) {
        userInitiatedJump = NO;
     
        NSString *sourceUrl = request.URL.absoluteString;
        NSString *callBackUrl = [self urlCallBack:sourceUrl navigationType:navigationType];
        NSString *escapedCallBackUrl = callBackUrl;
        
        if (navigationType == UIWebViewNavigationTypeOther) {
            escapedCallBackUrl = [callBackUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:escapedCallBackUrl]]];
        
        return NO;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.urlLabel.text = [NSString stringWithFormat:@"Loading: %@", request.URL.absoluteString];
    self.urlField.text = request.URL.absoluteString;

    return YES;
}

- (void)setLabel:(NSString *)label andUrl:(NSString *)url
{
    self.urlLabel.text = label;
    self.urlField.text = url;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setButtonsStatus];
    
    NSString *label = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *sourceUrl = self.webView.request.URL.absoluteString;
    
    BookmarkItem *historyItem = [[BookmarkItem alloc] initWithName:label
                                                               url:sourceUrl
                                                              date:[NSDate date]
                                                             folder:NO
                                                         permanent:NO];
    
    if ([self.bookmarkNavigationController.topViewController conformsToProtocol:@protocol(BookmarkItemDelegate)]) {
        historyItem.delegateController = (id <BookmarkItemDelegate>)self.bookmarkNavigationController.topViewController;
    }
    
    [self.bookmarksStorage addBookmark:historyItem toFolder:self.bookmarksStorage.historyFolder];
    [historyItem release];
    
    [self setLabel:label andUrl:sourceUrl];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setButtonsStatus];
    
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSString *sourceUrl = self.webView.request.URL.absoluteString;

    [self setLabel:logString andUrl:sourceUrl];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

# pragma mark - text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self dismissOpenPopoversAndActionSheet];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    userInitiatedJump = YES;
    
    [self loadUrl:textField.text];
    
    return YES;
}

- (void)searchTheText:(NSString *)text
{
    userInitiatedJump = YES;
    
    NSURL *searchUrl = [self.searchEngine searchUrlForText:text];
    [self.webView loadRequest:[NSURLRequest requestWithURL:searchUrl]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchTheText:self.searchBar.text];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissOpenPopoversAndActionSheet];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self dismissOpenPopoversAndActionSheet];
    return YES;
}

# pragma mark - Popover delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.popoverBookmark) {
        self.popoverBookmark = nil; // free memory
        
        // pop edit bookmark controller from navigation stack
        while (![self.bookmarkNavigationController.topViewController isKindOfClass:[BookmarksTableViewController class]]) {
            [self.bookmarkNavigationController popViewControllerAnimated:NO];
        }
        
        // close editing mode on top table view controller
        UIViewController *topViewController = self.bookmarkNavigationController.topViewController;
        if ([topViewController isKindOfClass:[UITableViewController class]]) {
            ((UITableViewController *)topViewController).editing = NO;
        }
        
    } else if (popoverController == self.popoverSaveBookmark) {
        self.popoverSaveBookmark = nil;
        self.bookmarkSaveTableViewController = nil;
        self.actionSheet = nil;
    }
}

- (void)dismissAndCleanNewBookmarkPopover
{
    if ([self.popoverSaveBookmark isPopoverVisible]) {
        [self.popoverSaveBookmark dismissPopoverAnimated:YES];
        self.popoverSaveBookmark = nil;
        self.bookmarkSaveTableViewController = nil;
    }
}

# pragma mark - Popover delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController == self.navigationController && !self.isIPad) {
        self.navigationController.navigationBarHidden = viewController == self;
    }
}

@end
