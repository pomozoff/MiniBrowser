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
@property (nonatomic, retain) TabPageScrollView *mainPageScrollView;
@property (nonatomic, retain) NSMutableArray *tabPageDataArray;
@property (nonatomic, retain) NSMutableIndexSet *indexesToDelete;
@property (nonatomic, retain) NSMutableIndexSet *indexesToInsert;
@property (nonatomic, retain) NSMutableIndexSet *indexesToReload;

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
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to add
    // example 1: inserting one page at the current index  
    NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];
    
    // example 2: appending 2 pages at the end of the page scroller 
    //NSRange range; range.location = self.tabPageDataArray.count; range.length = 2;
    //self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // example 3: inserting 2 pages at the beginning of the page scroller 
    //NSRange range; range.location = 0; range.length = 2;
    //self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    
    // we can only insert pages in DECK mode
    if (pageScrollView.viewMode == TabPageScrollViewModePage) {
        [self tabsPressed:self];
    } else {
        [self addPagesAtIndexSet:self.indexesToInsert];
        self.indexesToInsert = nil;
    }
}

- (IBAction)closeTabPressed:(id)sender
{
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to delete
    // example 1: deleting the page at the current index
    self.indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:[pageScrollView indexForSelectedPage]];
    
    // example 2: deleting the last 2 pages from the page scroller
    //NSRange range; range.location = self.tabPageDataArray.count - 2; range.length = 2;
    //self.indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // example 3: deleting the first 2 pages from the page scroller
    //NSRange range; range.location = 0; range.length = 2;
    //self.indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // we can only delete pages in DECK mode
    if (pageScrollView.viewMode == TabPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    } else {
        [self removePagesAtIndexSet:self.indexesToDelete];
        self.indexesToDelete = nil;
    }
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
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
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

- (void)loadUrl:(NSString *)url
{
    [self loadUrl:url inWebView:self.webView];
}

- (void)closePopupsAndLoadUrl:(NSString *)url
{
    userInitiatedJump = YES;
    [self dismissOpenPopoversAndActionSheet];
    [self loadUrl:url];
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
}

- (void)loadSettings
{
    return;
    
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

- (void)setButtonsStatus
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)loadPageScrollView
{
    /*
    TabPageData *pageData = [[TabPageData alloc] init];
    pageData.title = @"Yahoo";
    pageData.subtitle = @"yahoo.com";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];

    pageData = [[TabPageData alloc] init];
    pageData.title = @"Google";
    pageData.subtitle = @"google.com";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];
    
    pageData = [[TabPageData alloc] init];
    pageData.title = @"Wiki";
    pageData.subtitle = @"wiki.org";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];
    
    pageData = [[TabPageData alloc] init];
    pageData.title = @"Apple";
    pageData.subtitle = @"apple.com";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];
    
    pageData = [[TabPageData alloc] init];
    pageData.title = @"Flickr";
    pageData.subtitle = @"flickr.com";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];
    
    pageData = [[TabPageData alloc] init];
    pageData.title = @"AOL";
    pageData.subtitle = @"aol.com";
    [self.tabPageDataArray addObject:pageData];
    [pageData release];
    */
    
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
    [self setButtonsStatus];
    [self loadSettings];
    [self loadPageScrollView];
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

    // remember title and subtitle for page
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:selectedIndex];
    pageData.title = label;
    pageData.subtitle = url;
    
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
    
    UIViewController *topViewController = self.bookmarkNavigationController.topViewController;
    if ([topViewController conformsToProtocol:@protocol(BookmarkItemDelegate)]) {
        historyItem.delegateController = (id <BookmarkItemDelegate>)topViewController;
    }
    
    // remember new history item
    [self.bookmarksStorage addBookmark:historyItem toFolder:self.bookmarksStorage.historyFolder];
    [historyItem release];
    
    // print url and title
    [self setLabel:label andUrl:sourceUrl];

    // remove network activity star
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
    
    [self loadUrl:textField.text];

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
    } else if (pageData.view) {
        pageView = pageData.view;
    } else {
        static NSString *pageId = @"pageId";
        
        pageView = (PhonePageView *)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"iPhonePageView" owner:pageData options:nil] objectAtIndex:0];
            //pageView.reuseIdentifier = pageId;
            pageData.webView.delegate = self;
            pageData.view = pageView;
            
            if (pageData.subtitle) {
                [self loadUrl:pageData.subtitle inWebView:pageData.webView];
            }
        }
        
        // configure the page
        //UILabel *titleLabel = (UILabel *)[pageView viewWithTag:1];
        //titleLabel.text = pageData.title;
        
        //UIImageView *imageView = (UIImageView*)[pageView viewWithTag:2];
        //imageView.image = pageData.image;
        
        //UITextView *textView = (UITextView*)[pageView viewWithTag:3];
        //textView.text = @"some text here";
        
        //adjust content size of scroll view
        //UIScrollView *pageContentsScrollView = (UIScrollView *)[pageView viewWithTag:10];
        //pageContentsScrollView.scrollEnabled = NO; //initially disable scroll
        
        // set the pageView frame height
        CGRect frame = pageView.frame;
        frame.size.height = 420; 
        pageView.frame = frame; 

        //UIScrollView *scrollContentView = (UIScrollView *)[pageView.webView.subviews objectAtIndex:0];
        //scrollContentView.scrollEnabled = NO;
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
    
    if (!pageData.navController) {
        /*
        PhonePageView *page = (PhonePageView *)[scrollView pageAtIndex:index];
        UIScrollView *pageContentsScrollView = (UIScrollView *)[page viewWithTag:10];
        if (!page.isInitialized) {
            // prepare the page for interaction. This is a "second step" initialization of the page 
            // which we are deferring to just before the page is selected. While the page is initially
            // requeseted (pageScrollView:viewForPageAtIndex:) this extra step is not required and is preferably 
            // avoided due to performace reasons.  
            
            // asjust text box height to show all text
            UITextView *textView = (UITextView*)[page viewWithTag:3];
            CGFloat margin = 12;
            CGSize size = [textView.text sizeWithFont:textView.font
                                    constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
                                        lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = textView.frame;
            frame.size.height = size.height + 4 * margin;
            textView.frame = frame;
            
            // adjust content size of scroll view
            pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
            
            // mark the page as initialized, so that we don't have to do all of the above again 
            // the next time this page is selected
            page.isInitialized = YES;  
        }

        // enable scroll
        UIScrollView *pageContentsScrollView = (UIScrollView *)[self.webView.subviews objectAtIndex:0];
        pageContentsScrollView.scrollEnabled = YES;
        */
    }
    
    if (pageData) {
        self.webView = pageData.webView;
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
        // copy the toolbar items to the navigation controller
        //[pageData.navController.topViewController setToolbarItems:self.mainToolbar.items];
    } else {
        /*
        // add "edit" button to the toolbar
        UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didClickEditPage:)] autorelease];
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.mainToolbar.items];
        [items addObject:editButton];
        self.mainToolbar.items = items;
        */
    }
    
    // place navigation toolbar to view
    [self changeToolbar:self.tabsToolbar withToolbar:self.navigationToolbar];
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
}

// ******************************************************************************************************************************

#pragma mark - Reload Page


- (void)reloadPagesAtIndexSet:(NSIndexSet *)indexSet
{
    TabPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView reloadPagesAtIndexes:self.indexesToReload];
}

@end
