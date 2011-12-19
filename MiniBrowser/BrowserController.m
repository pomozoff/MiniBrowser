//
//  BrowserController.m
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BrowserController.h"
#import "SettingsController.h"
#import "BookmarksTableViewController.h"
#import "BookmarksStorageProtocol.h"
#import "BookmarkSaveTableViewController.h"
#import "BookmarksStorage.h"
#import "TabPageScrollView.h"
#import "TabPageData.h"
#import "PhonePageView.h"
#import "PageHeaderInfo.h"

@interface BrowserController()

@property (nonatomic, retain) SettingsController *settingsController;
@property (nonatomic, retain) BookmarksTableViewController *bookmarksTableViewController;
@property (nonatomic, retain) BookmarkSaveTableViewController *bookmarkSaveTableViewController;
@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;
@property (nonatomic, retain) UIPopoverController *popoverBookmark;
@property (nonatomic, retain) UIPopoverController *popoverAction;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UINavigationController *bookmarkNavigationController;

@property (nonatomic, retain) NSMutableArray *tabPageDataArray;
@property (nonatomic, retain) TabPageScrollView *mainPageScrollView;

@property (nonatomic, retain) NSMutableIndexSet *indexesToDelete;
@property (nonatomic, retain) NSMutableIndexSet *indexesToInsert;
@property (nonatomic, retain) NSMutableIndexSet *indexesToReload;

@property (nonatomic, retain) NSMutableDictionary *mapPageView;
@property (nonatomic, retain) NSMutableArray *webViewArray;

- (UIViewController *)headerInfoForPageAtIndex:(NSInteger)index;
- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet;
- (void)removePagesAtIndexSet:(NSIndexSet *)indexSet;
- (void)reloadPagesAtIndexSet:(NSIndexSet *)indexSet;

@end

@implementation BrowserController

@synthesize isIPad = _isIPad;
@synthesize xibNameScrollView = _xibNameScrollView;

@synthesize navigationBar = _navigationBar;
@synthesize searchBar = _searchBar;
@synthesize tabsToolbar = _tabsToolbar;
@synthesize addTabButton = _addTabButton;
@synthesize doneTabButton = _doneTabButton;
@synthesize navigationToolbar = _navigationView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize bookmarkButton = _bookmarkButton;
@synthesize actionButton = _actionButton;
@synthesize tabsButton = _tabsButton;
@synthesize urlField = _urlField;
@synthesize urlLabel = _urlLabel;

@synthesize webView = _webView;

@synthesize settingsController = _settingsController;
@synthesize bookmarksTableViewController = _bookmarksTableViewController;
@synthesize bookmarkSaveTableViewController = _bookmarkSaveTableViewController;
@synthesize bookmarksStorage = _bookmarksStorage;
@synthesize popoverBookmark = _popoverBookmark;
@synthesize popoverAction = _popoverAction;
@synthesize actionSheet = _actionSheet;
@synthesize bookmarkNavigationController = _bookmarkNavigationController;

@synthesize tabPageDataArray = _tabPageDataArray;
@synthesize mainPageScrollView = _mainPageScrollView;

@synthesize indexesToDelete = _indexesToDelete;
@synthesize indexesToInsert = _indexesToInsert;
@synthesize indexesToReload = _indexesToReload;

@synthesize mapPageView = _mapPageView;
@synthesize webViewArray = _webViewArray;

BOOL userInitiatedJump = NO;
NSString *const savedOpenedUrls = @"savedOpenedUrls";

// ******************************************************************************************************************************

#pragma mark - Properites initialization


- (SettingsController *)settingsController
{
    if (!_settingsController) {
        _settingsController = [[SettingsController alloc] init];
    }
    
    return _settingsController;
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

- (NSMutableArray *)tabPageDataArray
{
    if (!_tabPageDataArray) {
        _tabPageDataArray = [[NSMutableArray alloc] initWithCapacity:MAX_TABS_COUNT];
    }
    
    return _tabPageDataArray;
}

- (TabPageScrollView *)mainPageScrollView
{
    if (!_mainPageScrollView) {
        _mainPageScrollView = [[[NSBundle mainBundle] loadNibNamed:self.xibNameScrollView owner:self options:nil] objectAtIndex:0];
        _mainPageScrollView.delegate = self;
        _mainPageScrollView.dataSource = self;
    }
    
    return _mainPageScrollView;
}

- (NSMutableDictionary *)mapPageView
{
    if (!_mapPageView) {
        _mapPageView = [[NSMutableDictionary alloc] initWithCapacity:MAX_TABS_COUNT];
    }
    
    return _mapPageView;
}

- (NSMutableArray *)webViewArray
{
    if (!_webViewArray) {
        _webViewArray = [[NSMutableArray alloc] initWithCapacity:MAX_TABS_COUNT];
    }
    
    return _webViewArray;
}

// ******************************************************************************************************************************

#pragma mark - Buttons pressed


- (void)dismissOpenPopoversAndActionSheet
{
    if ([self.popoverBookmark isPopoverVisible]) {
        [self.popoverBookmark dismissPopoverAnimated:NO];
        self.popoverBookmark = nil;
    }
    
    if ([self.popoverAction isPopoverVisible]) {
        [self.popoverAction dismissPopoverAnimated:YES];
        self.popoverAction = nil;
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

- (IBAction)bookmarkPressed:(id)sender
{
    BOOL isBookmarkPopoverOpen = [self.popoverBookmark isPopoverVisible];

    [self dismissOpenPopoversAndActionSheet];
    [self finishEditing];
    
    if (isBookmarkPopoverOpen) {
        return;
    }
    
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
    BOOL isActionSheet = [self.actionSheet isVisible];

    [self dismissOpenPopoversAndActionSheet];
    [self finishEditing];
    
    if (isActionSheet) {
        return;
    }
    
    [self.actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)tabsPressed:(id)sender
{
	TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
	
	if (pageScrollView.viewMode == TabPageScrollViewModePage) {
		[pageScrollView deselectPageAnimated:YES];
	} else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
}

- (IBAction)newTabPressed:(id)sender
{
    //TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to add
    // example 1: inserting one page at the current index  
    //NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    //NSMutableIndexSet *indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];
    
    // example 2: appending 1 page at the end of the page scroller 
    NSRange range;
    range.location = self.tabPageDataArray.count;
    range.length = 1;
    NSMutableIndexSet *indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // example 3: inserting 2 pages at the beginning of the page scroller 
    //NSRange range; range.location = 0; range.length = 2;
    //self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    /*
    // we can only insert pages in DECK mode
    if (pageScrollView.viewMode == TabPageScrollViewModePage) {
        [self tabsPressed:self];
    } else {
        [self addPagesAtIndexSet:self.indexesToInsert];
        self.indexesToInsert = nil;
    }
    */
    
    [self addPagesAtIndexSet:indexesToInsert];
    [indexesToInsert release];
}

- (IBAction)closeTabPressed:(id)sender
{
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to delete
    // example 1: deleting the page at the current index
    NSMutableIndexSet *indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:[pageScrollView indexForSelectedPage]];
    
    // example 2: deleting the last 2 pages from the page scroller
    //NSRange range; range.location = self.tabPageDataArray.count - 2; range.length = 2;
    //self.indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // example 3: deleting the first 2 pages from the page scroller
    //NSRange range; range.location = 0; range.length = 2;
    //self.indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    /*
    // we can only delete pages in DECK mode
    if (pageScrollView.viewMode == TabPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    } else {
        [self removePagesAtIndexSet:self.indexesToDelete];
        self.indexesToDelete = nil;
    }
    */
    
    [self removePagesAtIndexSet:indexesToDelete];
    [indexesToDelete release];

    if (self.tabPageDataArray.count == 0) {
        [self newTabPressed:nil];
    }
}

- (void)closeCurrentPage
{
    [self closeTabPressed:nil];
}

// ******************************************************************************************************************************

#pragma mark - toolbar Actions


- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet
{
    if (self.tabPageDataArray.count >= MAX_TABS_COUNT) {
        self.addTabButton.enabled = NO;
        return;
    }
    
    // create new pages and add them to the data set 
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        TabPageData *pageData = [[[TabPageData alloc] init] autorelease];
        [self.tabPageDataArray insertObject:pageData atIndex:idx];
    }];
    
    // update the page scroller 
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView insertPagesAtIndexes:indexSet animated:YES];
}

- (void)removePagesAtIndexSet:(NSIndexSet *)indexSet
{
    self.webView = nil;

    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    NSArray *deletingObjects = [self.tabPageDataArray objectsAtIndexes:indexSet];
    for (TabPageData *pageData in deletingObjects) {
        NSUInteger index = [self.tabPageDataArray indexOfObject:pageData];
        NSNumber *key = [NSNumber numberWithInt:index];
        
        TabPageView *pageView = [self.mapPageView objectForKey:key];
        [self.webViewArray removeObject:pageView];
        
        [self.mapPageView removeObjectForKey:key];
    }
    
    // remove from the data set
    [self.tabPageDataArray removeObjectsAtIndexes:indexSet];
    
    // update the page scroller
    [pageScrollView deletePagesAtIndexes:indexSet animated:YES];
    
    self.addTabButton.enabled = YES;
}

// ******************************************************************************************************************************

#pragma mark - Memory Clean


- (void)cleanCache
{
    self.settingsController = nil;
    self.bookmarksTableViewController = nil;
    self.bookmarkSaveTableViewController = nil;
    self.bookmarksStorage = nil;
    self.popoverBookmark = nil;
    self.popoverAction = nil;
    self.actionSheet = nil;
    self.bookmarkNavigationController = nil;
    self.mainPageScrollView = nil;
}

- (void)freeProperties
{
    [self cleanCache];
    
    self.navigationBar = nil;
    self.navigationToolbar = nil;
    self.searchBar = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.bookmarkButton = nil;
    self.actionButton = nil;
    self.tabsButton = nil;
    self.urlField = nil;
    self.urlLabel = nil;
    self.webView = nil;
    self.tabPageDataArray = nil;
    
    self.indexesToInsert = nil;
}

// ******************************************************************************************************************************

#pragma mark - URL


- (BOOL)checkIsUrlEmpty:(NSString *)url
{
    NSString *trimmedUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isUrlEmpty = !trimmedUrl || [trimmedUrl isEqualToString:@""];
    
    self.actionButton.enabled = !isUrlEmpty;
    
    /*
    if (isUrlEmpty) {
        self.urlField.text = @"";
        self.urlLabel.text = @"Untitled";
    }
    */
    
    return isUrlEmpty;
}

- (void)loadUrl:(NSString *)url inWebView:(UIWebView *)webView
{
    if ([self checkIsUrlEmpty:url]) {
        return;
    }
    
    NSString *readyUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlObject = [NSURL URLWithString:readyUrl];
    
    if (!urlObject.scheme) {
        urlObject = [NSURL URLWithString:[@"http://" stringByAppendingString:urlObject.absoluteString]];
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:urlObject]];
}

- (void)closePopupsAndLoadUrl:(NSString *)url
{
    userInitiatedJump = YES;
    [self dismissOpenPopoversAndActionSheet];
    [self loadUrl:url inWebView:self.webView];
}

// ******************************************************************************************************************************

#pragma mark - Save/Load Settings


- (void)saveSettings
{
    NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:MAX_TABS_COUNT];
    for (TabPageData *pageData in self.tabPageDataArray) {
        if (pageData.subtitle) {
            [urlList addObject:pageData.subtitle];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(NSArray *)urlList forKey:savedOpenedUrls];
    [defaults synchronize];
    
    [urlList release];
}

- (void)loadSettings
{
    self.settingsController.currentSearchEngine = nil;
    self.searchBar.placeholder = self.settingsController.currentSearchEngine.name;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    [self.tabPageDataArray removeAllObjects];
    NSArray *urlList = [defaults objectForKey:savedOpenedUrls];
    for (NSString *url in urlList) {
        TabPageData *pageData = [[TabPageData alloc] init];
        pageData.title = @"";
        pageData.subtitle = url;
        [self.tabPageDataArray addObject:pageData];
        [pageData release];
    }
}

// ******************************************************************************************************************************

#pragma mark - Object lifecycle


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            // Custom initialization
    }
    
    return self;
}
*/

- (void)addObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(saveSettings)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(loadSettings)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
}

- (void)removeObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self 
                      name:UIApplicationWillResignActiveNotification 
                    object:nil];
    
    [center removeObserver:self 
                      name:UIApplicationWillEnterForegroundNotification
                    object:nil];
}

- (void)updateButtonsStatus:(UIWebView *)webView
{
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)loadPageScrollView
{
    if (self.tabPageDataArray.count == 0) {
        TabPageData *pageData = [[TabPageData alloc] init];
        pageData.title = @"Unitiled";
        pageData.subtitle = @"";
        [self.tabPageDataArray addObject:pageData];
        [pageData release];
    }
    
    // now that we have the data, initialize the page scroll view
    [self.view addSubview:self.mainPageScrollView];
    
    // uncomment this line if you want to select a page initially, before TabPageScrollView is shown, 
    [self.mainPageScrollView selectPageAtIndex:0 animated:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
    [self loadSettings];
    [self loadPageScrollView];
    [self updateButtonsStatus:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Correct view frame to show the status bar
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.view.frame = CGRectOffset(self.view.frame, 0, statusBarHeight);
    
//    [self loadSettings];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self freeProperties];
    [self removeObservers];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [self saveSettings];
    [self cleanCache];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc
{
	[self freeProperties];
    [super dealloc];
}

// ******************************************************************************************************************************

#pragma mark - URL Callback


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

// ******************************************************************************************************************************

#pragma mark - WebView Delegate


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
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:escapedCallBackUrl]]];
        
        return NO;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //self.urlLabel.text = [NSString stringWithFormat:@"Loading: %@", request.URL.absoluteString];
    self.urlLabel.text = @"Loading";
    self.urlField.text = request.URL.absoluteString;

    return YES;
}

- (void)setLabel:(NSString *)label andUrl:(NSString *)url withWebView:(UIWebView *)webView
{
    NSUInteger index = [self.webViewArray indexOfObject:webView];
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    pageData.title = label;
    pageData.subtitle = url;

    // set title and url in view
    if (webView == self.webView) {
        self.urlLabel.text = label;
        self.urlField.text = url;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateButtonsStatus:webView];
    
    NSString *label = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *sourceUrl = webView.request.URL.absoluteString;
    
    // print url and title
    [self setLabel:label andUrl:sourceUrl withWebView:webView];
    
    BookmarkItem *historyItem = [[BookmarkItem alloc] initWithName:label
                                                               url:sourceUrl
                                                              date:[NSDate date]
                                                            folder:NO
                                                         permanent:NO];
    
    UIViewController *topViewController = self.bookmarkNavigationController.topViewController;
    if ([topViewController conformsToProtocol:@protocol(BookmarkItemDelegate)]) {
        historyItem.delegateController = (id <BookmarkItemDelegate>)topViewController;
    }
    
    // remember new history item
    [self.bookmarksStorage addBookmark:historyItem toFolder:self.bookmarksStorage.historyFolder];
    [historyItem release];

    // remove network activity star
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateButtonsStatus:webView];
    
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSString *sourceUrl = webView.request.URL.absoluteString;

    [self setLabel:logString andUrl:sourceUrl withWebView:webView];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// ******************************************************************************************************************************

#pragma mark - SearchField and TextField Delegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissOpenPopoversAndActionSheet];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkIsUrlEmpty:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    userInitiatedJump = YES;
    
    [self loadUrl:textField.text inWebView:self.webView];

    /*
     TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
     NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
     TabPageData *pageData = [self.tabPageDataArray objectAtIndex:selectedIndex]; 
     
     pageData.title = textField.text;   
     
     [textField resignFirstResponder];
     textField.hidden = YES;
     textField.delegate = nil;
     
     self.indexesToReload = [[NSMutableIndexSet alloc] initWithIndex:selectedIndex];
     
     if (pageScrollView.viewMode == TabPageScrollViewModePage) {
         [pageScrollView deselectPageAnimated:YES];
     } else {
         [self reloadPagesAtIndexSet:self.indexesToReload];
     }
    */
    
    return YES;
}

- (void)searchTheText:(NSString *)text
{
    userInitiatedJump = YES;
    
    NSURL *searchUrl = [self.settingsController.currentSearchEngine searchUrlForText:text];
    [self.webView loadRequest:[NSURLRequest requestWithURL:searchUrl]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchTheText:self.searchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self dismissOpenPopoversAndActionSheet];
    return YES;
}

// ******************************************************************************************************************************

#pragma mark - Popover Delegate


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
    } else if (popoverController == self.popoverAction) {
        self.actionSheet = nil;
        self.popoverAction = nil;
        self.bookmarkSaveTableViewController = nil;
    }
}

- (void)dismissPopoverActionAndCleanUp
{
    if ([self.popoverAction isPopoverVisible]) {
        [self.popoverAction dismissPopoverAnimated:YES];
    }

    self.popoverAction = nil;
    self.bookmarkSaveTableViewController = nil;
}

// ******************************************************************************************************************************

#pragma mark - NavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.isIPad) {
        BOOL hideElements = viewController == self;
        [self.navigationController setToolbarHidden:hideElements animated:YES];
        if (navigationController == self.navigationController) {
            self.navigationController.navigationBarHidden = hideElements;
        }
    }
}

// ******************************************************************************************************************************

#pragma mark - Actionsheet callback


- (void)displaySaveNewBookmarkPopoverForBarButton:(UIBarButtonItem *)barItem
{
    [self dismissOpenPopoversAndActionSheet];
    
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
    self.bookmarkSaveTableViewController.currentFolder = currentFolder;
    self.bookmarkSaveTableViewController.delegateBrowserController = self;
    self.bookmarkSaveTableViewController.title = barItem.title;
    
    newBookmark.delegateController = bookmarkTVC ? bookmarkTVC : self.bookmarksTableViewController;
    [newBookmark release];
    
    if (self.isIPad) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        
        [navigationController pushViewController:self.bookmarkSaveTableViewController animated:NO];
        self.popoverAction = popover;
        
        [popover release];
        [navigationController release];
        
        self.popoverAction.delegate = self;
        
        [self.popoverAction presentPopoverFromBarButtonItem:barItem
                                   permittedArrowDirections:UIPopoverArrowDirectionUp
                                                   animated:YES];
    } else {
        [self.navigationController pushViewController:self.bookmarkSaveTableViewController animated:YES];
    }
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

// ******************************************************************************************************************************

#pragma mark - TabPageScrollViewDataSource


- (NSInteger)numberOfPagesInScrollView:(TabPageScrollView *)scrollView   // Default is 0 if not implemented
{
	return self.tabPageDataArray.count;
}

- (UIView *)pageScrollView:(TabPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        UIView *navBarCopy = [[[UINavigationBar alloc] initWithFrame:pageData.navController.navigationBar.frame] autorelease];
        return navBarCopy;
    }
    
    return nil;
}

- (TabPageView *)pageScrollView:(TabPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    TabPageView *pageView = nil;
    
    if (pageData.navController) {
        pageView = (TabPageView *)pageData.navController.topViewController.view;
    } else {
        pageView = [self.mapPageView objectForKey:[NSNumber numberWithInt:index]];
    }
    
    if (!pageView) {
        static NSString *pageId = @"pageId";
        
        pageView = (PhonePageView *)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"iPhonePageView" owner:self options:nil] objectAtIndex:0];
            //pageView.reuseIdentifier = pageId;
            //pageData.webView.delegate = self;
            
            [self.mapPageView setObject:pageView forKey:[NSNumber numberWithInt:index]];
            [self.webViewArray addObject:pageView.webView];
            
            if (pageData.subtitle) {
                [self loadUrl:pageData.subtitle inWebView:pageView.webView];
            }
        }
    }

    return pageView;
}

- (NSString *)pageScrollView:(TabPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return headerInfo.title;
}

- (NSString *)pageScrollView:(TabPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return headerInfo.subtitle;
}

- (UIViewController *)headerInfoForPageAtIndex:(NSInteger)index
{
    /*
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // in this sample project, the page at index 0 is a navigation controller. 
        return pageData.navController.topViewController;
    } else {
        return [self.tabPageDataArray objectAtIndex:index];
    }
    */
    
    return [self.tabPageDataArray objectAtIndex:index];
}

// ******************************************************************************************************************************

#pragma mark - TabPageScrollViewDelegate


- (void)changeToolbar:(UIToolbar *)hideToolbar withToolbar:(UIToolbar *)showToolbar
{
    [hideToolbar removeFromSuperview];
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGSize navBarSize = showToolbar.frame.size;
    showToolbar.frame = CGRectMake(0, appFrame.size.height - navBarSize.height, navBarSize.width, navBarSize.height);
    [self.view insertSubview:showToolbar atIndex:0];
}

- (void)pageScrollView:(TabPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    
    if (pageData) {
        TabPageView *pageView = [self.mapPageView objectForKey:[NSNumber numberWithInt:index]];
        self.webView = pageView.webView;        
        self.urlLabel.text = pageData.title;
        self.urlField.text = pageData.subtitle;
    }
}

- (void)pageScrollView:(TabPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    
    if (pageData.navController) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:pageData.navController animated:NO];
    }
    
    // place navigation toolbar to view
    [self changeToolbar:self.tabsToolbar withToolbar:self.navigationToolbar];
    
    // update backs/forward buttons
    [self updateButtonsStatus:self.webView];
}

- (void)pageScrollView:(TabPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    
    if (!pageData.navController) {
        // disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
        /*
        TabPageView *page = [scrollView pageAtIndex:index];
        UIScrollView *scrollContentView = (UIScrollView *)[page viewWithTag:10];
        UIScrollView *scrollContentView = (UIScrollView *)[self.webView.subviews objectAtIndex:0];
        scrollContentView.scrollEnabled = NO;
        
        // remove "edit" button from toolbar
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.mainToolbar.items];
        [items removeLastObject];
        self.mainToolbar.items = items;
        */
    }
}

- (void)pageScrollView:(TabPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    // Now the page scroller is in DECK mode. 
    // Complete an add/remove pages request if one is pending
    if (self.indexesToDelete) {
        [self removePagesAtIndexSet:self.indexesToDelete];
        self.indexesToDelete = nil;
    }
    if (self.indexesToInsert) {
        [self addPagesAtIndexSet:self.indexesToInsert];
        self.indexesToInsert = nil;
    }
    
    // place tabs toolbar to view
    [self changeToolbar:self.navigationToolbar withToolbar:self.tabsToolbar];

    self.addTabButton.enabled = (self.tabPageDataArray.count < MAX_TABS_COUNT);
}

// ******************************************************************************************************************************

#pragma mark - Reload Page


- (void)reloadPagesAtIndexSet:(NSIndexSet *)indexSet
{
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView reloadPagesAtIndexes:self.indexesToReload];
}

@end
