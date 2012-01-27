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
#import "UIWebView+Extended.h"

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

- (UIViewController *)headerInfoForPageAtIndex:(NSInteger)index;
- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet;
- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet animated:(BOOL)animated;
- (void)removePagesAtIndexSet:(NSIndexSet *)indexSet;
- (void)reloadPagesAtIndexSet:(NSIndexSet *)indexSet;
- (void)putPreview:(UIImageView *)preview onPageView:(TabPageView *)pageView;

@end

@implementation BrowserController

@synthesize isIPad = _isIPad;
@synthesize xibNameScrollView = _xibNameScrollView;
@synthesize xibNamePageView = _xibNameTabPageView;
@synthesize maxTabsAmount = _maxTabsAmount;

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
        _tabPageDataArray = [[NSMutableArray alloc] initWithCapacity:self.maxTabsAmount];
    }
    
    return _tabPageDataArray;
}

- (TabPageScrollView *)mainPageScrollView
{
    if (!_mainPageScrollView) {
        _mainPageScrollView = [[[NSBundle mainBundle] loadNibNamed:self.xibNameScrollView owner:self options:nil] objectAtIndex:0];
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

- (void)closePageAtIndex:(NSInteger)index
{
    //TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
    
    // create an index set of the pages we wish to delete
    // example 1: deleting the page at the current index
    NSMutableIndexSet *indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:index];
    
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
    self.webView = nil;
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
	if (self.mainPageScrollView.viewMode == TabPageScrollViewModePage) {
		[self.mainPageScrollView deselectPageAnimated:YES];
	} else {
		[self.mainPageScrollView selectPageAtIndex:[self.mainPageScrollView indexForSelectedPage] animated:YES];
	}
}

- (void)addNewTabAnimated:(BOOL)animated
{
    NSRange range;
    range.location = self.tabPageDataArray.count;
    range.length = 1;
    NSMutableIndexSet *indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    [self addPagesAtIndexSet:indexesToInsert animated:animated];
    
    [indexesToInsert release];
}

- (IBAction)newTabPressed:(id)sender
{
    //TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
    
    // create an index set of the pages we wish to add
    // example 1: inserting one page at the current index  
    //NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    //self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];
    
    // example 2: appending 2 pages at the end of the page scroller 
    //NSRange range; range.location = self.tabPageDataArray.count; range.length = 2;
    //self.indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
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

    NSRange range;
    range.location = self.tabPageDataArray.count;
    range.length = 1;
    NSMutableIndexSet *indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
     */

    /*
    TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
    NSInteger selectedPageIndex = [self.mainPageScrollView indexForSelectedPage];
    NSMutableIndexSet *indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];
   */
    [self addNewTabAnimated:YES];
}

- (IBAction)closeTabPressed:(id)sender
{
    [self closePageAtIndex:[self.mainPageScrollView indexForSelectedPage]];
}

- (void)closeCurrentPage
{
    [self closeTabPressed:nil];
}

// ******************************************************************************************************************************

#pragma mark - toolbar Actions


- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet animated:(BOOL)animated
{
    if (self.tabPageDataArray.count >= self.maxTabsAmount) {
        self.addTabButton.enabled = NO || self.isIPad;
        return;
    }
    
    // create new pages and add them to the data set 
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        TabPageData *pageData = [[TabPageData alloc] init];
        pageData.webViewDelegate = self;
        pageData.index = index;
        [self.tabPageDataArray insertObject:pageData atIndex:index];
        [pageData release];
    }];
    
    // update the page scroller 
    //TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
    
    [self.mainPageScrollView insertPagesAtIndexes:indexSet animated:animated];
}

- (void)addPagesAtIndexSet:(NSIndexSet *)indexSet
{
    [self addPagesAtIndexSet:indexSet animated:YES];
}

- (void)removePagesAtIndexSet:(NSIndexSet *)indexSet
{
    //TabPageScrollView *pageScrollView = [self.view.subviews lastObject];

    // remove from the data set
    [self.tabPageDataArray removeObjectsAtIndexes:indexSet];
    
    // update the page scroller
    [self.mainPageScrollView deletePagesAtIndexes:indexSet animated:YES];
    
    self.addTabButton.enabled = YES;

    if (self.isIPad) {
        TabPageView *lastPageView = [self.mainPageScrollView pageAtIndex:(self.tabPageDataArray.count - 1)];
        if (!lastPageView.isNewTabButton) {
            [self addNewTabAnimated:NO];
        }
    } else if (self.tabPageDataArray.count == 0) {
        [self newTabPressed:nil];
    }
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
    self.webView = nil;
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
    self.tabPageDataArray = nil;
    
    self.indexesToInsert = nil;
    self.mainPageScrollView = nil;
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

- (void)loadUrl:(NSString *)url
{
    NSInteger selectedIndex = [self.mainPageScrollView indexForSelectedPage];
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:selectedIndex]; 

    [pageData loadUrl:url];
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
    NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:self.maxTabsAmount];
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
        pageData.webViewDelegate = self;
        pageData.title = @"";
        pageData.subtitle = url;

        [self.tabPageDataArray addObject:pageData];

        [pageData release];
    }
}

// ******************************************************************************************************************************

#pragma mark - Object lifecycle


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
        pageData.webViewDelegate = self;
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
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    self.view.frame = CGRectOffset(self.view.frame, 0, statusBarFrame.size.height);
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
{    // Return YES for supported orientations

    return YES;
}

- (CGRect)rotateFrame:(CGRect)frame
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat tmp = frame.size.width;
    frame.size.width = frame.size.height;
    frame.size.height = tmp;
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        frame.size.height -= statusBarFrame.size.height;
        frame.size.width  += statusBarFrame.size.height;
    } else {
        frame.size.height -= statusBarFrame.size.width;
        frame.size.width  += statusBarFrame.size.width;
    }
    
    return frame;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL sameOrientation =
    ( UIInterfaceOrientationIsLandscape(orientation) && UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ) ||
    ( UIInterfaceOrientationIsPortrait(orientation)  && UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) );
    
    if (!sameOrientation) {
        [self.tabPageDataArray enumerateObjectsUsingBlock:^(TabPageData *pageData, NSUInteger index, BOOL *stop) {
            TabPageView *pageView = [self.mainPageScrollView pageAtIndex:index];
            
            if (![self.mainPageScrollView.subviews containsObject:pageView]) {
                pageView.bounds = [self rotateFrame:pageView.bounds];
            }
            
            if (![pageView.subviews containsObject:pageData.webView]) {
                pageData.webView.frame = [self rotateFrame:pageData.webView.frame];
            }
            
            if (![pageView.subviews containsObject:pageData.previewImageView]) {
                pageData.previewImageView.frame = [self rotateFrame:pageData.previewImageView.frame];
            }

            pageView.identityFrame = [self rotateFrame:pageView.identityFrame];
            pageData.pageViewSize = pageView.identityFrame.size;
            
            [pageData makeScreenShotOfTheView:pageData.webView];
            [self putPreview:pageData.previewImageView onPageView:pageView];
            
            if (self.mainPageScrollView.viewMode == TabPageScrollViewModeDeck || self.mainPageScrollView.selectedPage != pageView) {
                [self.mainPageScrollView setOriginForPage:pageView atIndex:index];
            }
        }];
    }
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


- (void)setLabel:(NSString *)label andUrl:(NSString *)url withWebView:(UIWebView *)webView
{
    // set title and url in view
    if (webView == self.webView) {
        self.urlLabel.text = label;
        self.urlField.text = url;
    }
}

- (void)loadWebView:(NSArray *)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    UIWebView *webView = (UIWebView *)[arguments objectAtIndex:0];
    NSURLRequest *request=(NSURLRequest *)[arguments objectAtIndex:1];
    
    webView.isThreaded = YES;
    [webView loadRequest:request];
    
    [pool drain];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (userInitiatedJump || navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        userInitiatedJump = NO;
     
        NSString *sourceUrl = request.URL.absoluteString;
        NSString *callBackUrl = [self urlCallBack:sourceUrl navigationType:navigationType];
        NSURL *theUrl = [NSURL URLWithString:callBackUrl];
        
        [webView loadRequest:[NSURLRequest requestWithURL:theUrl]];
        
        return NO;
    }
    
    [self setLabel:@"Loading" andUrl:request.URL.absoluteString withWebView:webView];
    
    if (webView == self.webView) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    if (!webView.isThreaded) {
        NSArray *arguments = [NSArray arrayWithObjects:webView, request, nil];
        [NSThread setThreadPriority:0.5f];
        [NSThread detachNewThreadSelector:@selector(loadWebView:) toTarget:self withObject:arguments];

        return NO;
    }

    return YES;
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
    if (webView == self.webView) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateButtonsStatus:webView];
    
    NSString *logString = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSString *sourceUrl = webView.request.URL.absoluteString;

    [self setLabel:logString andUrl:sourceUrl withWebView:webView];
    
    if (webView == self.webView) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

// ******************************************************************************************************************************

#pragma mark - SearchField and TextField Delegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissOpenPopoversAndActionSheet];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    userInitiatedJump = YES;
    
    [self loadUrl:textField.text];

    /*
     TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
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
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:searchUrl];
    [self.webView loadRequest:urlRequest];
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

- (NSUInteger)maxPagesAmount
{
    return self.maxTabsAmount;
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

- (void)drawCloseButtonForPage:(TabPageView *)pageView atIndex:(NSInteger)index
{
    if (!self.isIPad) {
        return;
    }
    
    if (pageView.isNewTabButton) {
        [pageView.closeButton removeFromSuperview];
        if (![pageView.subviews containsObject:pageView.buttonNewTabView]) {
            [pageView addSubview:pageView.buttonNewTabView];
        }
    } else if (![pageView.subviews containsObject:pageView.closeButton]) {
        [pageView addSubview:pageView.closeButton];
    }
}

- (TabPageView *)pageScrollView:(TabPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    TabPageView *pageView = nil;
    
    if (pageData.navController) {
        pageView = (TabPageView *)pageData.navController.topViewController.view;
    }
    
    if (!pageView) {
        static NSString *pageId = @"pageId";
        
        //pageView = (TabPageView *)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:self.xibNamePageView owner:pageData options:nil] objectAtIndex:0];
            pageView.reuseIdentifier = pageId;
            
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                pageView.frame = [self rotateFrame:pageView.frame];
            }

            // prepare new tab to use right now
            if (index < (self.tabPageDataArray.count - 1)) {
                [pageView.buttonNewTabView removeFromSuperview];
                self.webView = pageData.webView;
            } else {
                pageView.isNewTabButton = YES;
            }
            
            self.webView.frame = pageView.frame;
        }
        
        if ([pageView.subviews indexOfObject:pageData.previewImageView] == NSNotFound) {
            [pageView insertSubview:pageData.previewImageView belowSubview:pageView.closeButton];
        }

        if ([pageData.title isEqualToString:@""] && ![pageData.subtitle isEqualToString:@""]) {
            pageData.pageViewSize = pageView.identityFrame.size;
            [pageData loadUrl];
        }
        
        [self drawCloseButtonForPage:pageView atIndex:index];
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

#pragma mark - preview


- (void)putPreview:(UIImageView *)preview onPageView:(TabPageView *)pageView
{
    [pageView insertSubview:preview belowSubview:pageView.closeButton];
}

- (void)placeScreenshotOnPageViewFromPageData:(TabPageData *)pageData
{
    NSUInteger index = [self.tabPageDataArray indexOfObject:pageData];
    if (index == NSNotFound) {
        return;
    }
    
    TabPageView *pageView = [self.mainPageScrollView pageAtIndex:index];
    
    if (self.mainPageScrollView.viewMode == TabPageScrollViewModeDeck || pageData.webView != self.webView) {
        [self putPreview:pageData.previewImageView onPageView:pageView];
    }
    
    [self.mainPageScrollView updateHeaderForPage:pageView WithIndex:index];
}

// ******************************************************************************************************************************

#pragma mark - TabPageScrollViewDelegate


- (void)replaceToolbar:(UIToolbar *)hideToolbar withToolbar:(UIToolbar *)showToolbar
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
    
    self.webView = pageData.webView;
    self.urlLabel.text = pageData.title;
    self.urlField.text = pageData.subtitle;
    
    TabPageView *pageView = [scrollView pageAtIndex:index];

    // add new tab if it's an iPad
    // and remove default image view
    if (self.isIPad && pageView.isNewTabButton) {
        [pageView.buttonNewTabView removeFromSuperview];
        pageView.isNewTabButton = NO;
        [self addNewTabAnimated:NO];
    }
    
    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)pageScrollView:(TabPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    TabPageData *pageData = [self.tabPageDataArray objectAtIndex:index];
    
    if (pageData.navController) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:pageData.navController animated:NO];
    }
    
    // place navigation toolbar to view
    [self replaceToolbar:self.tabsToolbar withToolbar:self.navigationToolbar];
    
    // update backs/forward buttons
    [self updateButtonsStatus:self.webView];
    
    // remove webView's screenshot
    [pageData.previewImageView removeFromSuperview];
    
    TabPageView *pageView = [scrollView pageAtIndex:index];
    CGRect frame = pageView.identityFrame;
    
    frame.origin.x = 0.0f;
    frame.origin.y = 0.0f;

    // cut webview height with pageHeader height
    frame.size.height -= self.mainPageScrollView.pageHeaderView.frame.size.height;
    self.webView.frame = frame;
    
    // place webView to the screen
    [pageView addSubview:pageData.webView];
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
    
    // remove preview
    //[pageData.previewImageView removeFromSuperview];

    TabPageView *pageView = [scrollView pageAtIndex:index];
    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    // return full webview size
    CGRect frame = pageData.webView.frame;
    frame.size.width = pageView.identityFrame.size.width;
    frame.size.height = pageView.identityFrame.size.height;
    pageData.webView.frame = frame;
    pageData.previewImageView.frame = frame;
    
    // get screenshot of the current webView
    pageData.pageViewSize = pageView.identityFrame.size;
    
    // place a preview on pageView
    [self putPreview:pageData.previewImageView onPageView:pageView];
    
    [pageData.webView removeFromSuperview];
    
    [self drawCloseButtonForPage:pageView atIndex:index];
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
    [self replaceToolbar:self.navigationToolbar withToolbar:self.tabsToolbar];
    
    // Enable "new tab" button if amount of tabs less than max tabs count
    self.addTabButton.enabled = (self.tabPageDataArray.count < self.maxTabsAmount);
}

// ******************************************************************************************************************************

#pragma mark - Reload Page


- (void)reloadPagesAtIndexSet:(NSIndexSet *)indexSet
{
    //TabPageScrollView *pageScrollView = [self.view.subviews lastObject];
    
    [self.mainPageScrollView reloadPagesAtIndexes:self.indexesToReload];
}

@end
