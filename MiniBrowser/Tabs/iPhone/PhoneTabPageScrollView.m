//
//  PhoneTabPageScrollView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 07.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "PhoneTabPageScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface PhoneTabPageScrollView()

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger numberOfFreshPages;
@property (nonatomic, assign) NSRange visibleIndexes;

@property (nonatomic, retain) NSMutableArray *visiblePages;
@property (nonatomic, retain) NSMutableArray *deletedPages;
@property (nonatomic, retain) NSMutableDictionary *reusablePages;

@property (nonatomic, retain) TabPageView *selectedPage;

@property (nonatomic, retain) NSIndexSet *indexesBeforeVisibleRange; 
@property (nonatomic, retain) NSIndexSet *indexesWithinVisibleRange; 
@property (nonatomic, retain) NSIndexSet *indexesAfterVisibleRange; 

@property (nonatomic, assign) BOOL isPendingScrolledPageUpdateNotification;

- (void)reloadData; 
- (TabPageView *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex;
- (void)addPageToScrollView:(TabPageView *)page atIndex:(NSInteger)index;
- (void)preparePage:(TabPageView *)page forMode:(TabPageScrollViewMode)mode;
- (void)updateVisiblePages;
- (void)setAlphaForPage:(TabPageView *)page;
- (NSInteger)indexForSelectedPage;
- (void)setViewMode:(TabPageScrollViewMode)mode animated:(BOOL)animated;
- (void)initHeaderForPageAtIndex:(NSInteger)index;
- (void)initDeckTitlesForPageAtIndex:(NSInteger)index;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)shiftPage:(TabPageView *)page withOffset:(CGFloat)offset;
- (void)updateScrolledPage:(TabPageView *)page index:(NSInteger)index;
- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index;

@end

@implementation PhoneTabPageScrollView

@synthesize userHeaderView = _userHeaderView;

@synthesize pageDeckBackgroundView = _pageDeckBackgroundView;
@synthesize pageHeaderView = _pageHeaderView;

@synthesize pageDeckTitleLabel = _pageDeckTitleLabel;
@synthesize pageDeckSubtitleLabel = _pageDeckSubtitleLabel;

@synthesize scrollView = _scrollView;
@synthesize scrollViewTouch = _scrollViewTouch;

@synthesize pageControl = _pageControl;
@synthesize pageControlTouch = _pageControlTouch;

@synthesize numberOfPages = _numberOfPages;
@synthesize numberOfFreshPages = _numberOfFreshPages;
@synthesize visibleIndexes = _visibleIndexes;

@synthesize visiblePages = _visiblePages;
@synthesize deletedPages = _deletedPages;
@synthesize reusablePages = _reusablePages;

@synthesize selectedPage = _selectedPage;

@synthesize indexesBeforeVisibleRange = _indexesBeforeVisibleRange;
@synthesize indexesWithinVisibleRange = _indexesWithinVisibleRange;
@synthesize indexesAfterVisibleRange = _indexesAfterVisibleRange;

@synthesize isPendingScrolledPageUpdateNotification = _isPendingScrolledPageUpdateNotification;

// ******************************************************************************************************************************

#pragma mark - Properites initialization

- (NSMutableArray *)visiblePages
{
    if (!_visiblePages) {
        _visiblePages = [[NSMutableArray alloc] initWithCapacity:VISIBLE_PAGES_COUNT];
    }
    
    return _visiblePages;
}

- (NSMutableArray *)deletedPages
{
    if (!_deletedPages) {
        _deletedPages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _deletedPages;
}

- (NSMutableDictionary *)reusablePages
{
    if (!_reusablePages) {
        _reusablePages = [[NSMutableDictionary alloc] initWithCapacity:REUSABLE_PAGES_COUNT];
    }
    
    return _reusablePages;
}

// ******************************************************************************************************************************

#pragma mark - Controller Lifecycle


- (void)awakeFromNib
{
    [super awakeFromNib];
    
	// set gradient for background view
	CAGradientLayer *glayer = [CAGradientLayer layer];
	glayer.frame = self.pageDeckBackgroundView.bounds;
	UIColor *topColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];    //light blue-gray
	UIColor *bottomColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]; //dark blue-gray
	glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    [self.pageDeckBackgroundView.layer insertSublayer:glayer atIndex:0];
	
	// set tap gesture recognizer for page selection
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureFrom:)];
	[self.scrollView addGestureRecognizer:recognizer];
	recognizer.delegate = self;
	[recognizer release];
	
	// setup scrollView
	self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.clipsToBounds = NO;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
	self.pageControlTouch.receiver = self.pageControl;
	self.scrollViewTouch.receiver = self.scrollView;
	
	// setup pageSelector
	[self.pageControl addTarget:self action:@selector(didChangePageValue:) forControlEvents:UIControlEventValueChanged];
	
	// default number of pages 
	self.numberOfPages = 1;
	
	// set initial visible indexes (page 0)
	_visibleIndexes.location = 0;
	_visibleIndexes.length = 1;
    
	[self reloadData];
}

- (void)freeOutlets
{
    self.pageDeckBackgroundView = nil;
    self.pageHeaderView = nil;
    self.userHeaderView = nil;

    self.pageDeckTitleLabel = nil;
    self.pageDeckSubtitleLabel = nil;
    
    self.scrollView = nil;
    self.scrollViewTouch = nil;
    
    self.pageControl = nil;
    self.pageControlTouch = nil;
}

- (void)dealloc
{
    [self freeOutlets];
    
    self.visiblePages = nil;
    self.deletedPages = nil;
    self.reusablePages = nil;

    self.selectedPage = nil;

    self.indexesBeforeVisibleRange = nil;
    self.indexesWithinVisibleRange = nil;
    self.indexesAfterVisibleRange = nil;

    [super dealloc];
}

// *******************************************************************************************************************************

#pragma mark - View Management


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
	self.scrollView.contentSize = CGSizeMake(self.numberOfPages * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
}

// *******************************************************************************************************************************

#pragma mark - Info


- (NSInteger)numberOfPages 
{
	return _numberOfPages;
}

- (TabPageView *)pageAtIndex:(NSInteger)index            // returns nil if page is not visible or the index is out of range
{
	if (index == NSNotFound || index < self.visibleIndexes.location || index > self.visibleIndexes.location + self.visibleIndexes.length-1) {
		return nil;
	}
    
	return [self.visiblePages objectAtIndex:index - self.visibleIndexes.location];
}

// *******************************************************************************************************************************

#pragma mark Page Selection


- (NSInteger)indexForSelectedPage
{
    return [self indexForVisiblePage:self.selectedPage];
}

- (NSInteger)indexForVisiblePage:(TabPageView *)page
{
	NSInteger index = [self.visiblePages indexOfObject:page];
	if (index != NSNotFound) {
        return self.visibleIndexes.location + index;
    }
    
    return NSNotFound;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
	CGPoint offset = CGPointMake(index * self.scrollView.frame.size.width, 0);
	[self.scrollView setContentOffset:offset animated:animated];
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    // ignore if there are no pages or index is invalid
    if (index == NSNotFound || self.numberOfPages == 0) {
        return;
    }
    
	if (index != [self indexForSelectedPage]) {
        // rebuild self.visibleIndexes
        BOOL isLastPage = (index == self.numberOfPages - 1);
        BOOL isFirstPage = (index == 0); 
        NSInteger selectedVisibleIndex; 
        if (self.numberOfPages == 1) {
            _visibleIndexes.location = index;
            _visibleIndexes.length = 1;
            selectedVisibleIndex = 0;
        } else if (isLastPage) {
            _visibleIndexes.location = index - 1;
            _visibleIndexes.length = 2;
            selectedVisibleIndex = 1;
        } else if(isFirstPage){
            _visibleIndexes.location = index;
            _visibleIndexes.length = 2;                
            selectedVisibleIndex = 0;
        } else {
            _visibleIndexes.location = index - 1;
            _visibleIndexes.length = 3;           
            selectedVisibleIndex = 1;
        }
        
        // update the scrollView content offset
        self.scrollView.contentOffset = CGPointMake(index * self.scrollView.frame.size.width, 0);
        
        // reload the data for the new indexes
        [self reloadData];
        
        // update self.selectedPage
        self.selectedPage = [self.visiblePages objectAtIndex:selectedVisibleIndex];
        
        // update the page selector (pageControl)
        [self.pageControl setCurrentPage:index];
	}
    
	[self setViewMode:TabPageScrollViewModePage animated:animated];
}

- (void)deselectPageAnimated:(BOOL)animated
{
    // ignore if there are no pages or no self.selectedPage
    if (!self.selectedPage || self.numberOfPages == 0) {
        return;
    }
    
    // Before moving back to DECK mode, refresh the selected page
    NSInteger visibleIndex = [self.visiblePages indexOfObject:self.selectedPage];
    NSInteger selectedPageScrollIndex = [self indexForSelectedPage];
    CGRect identityFrame = self.selectedPage.identityFrame;
    CGRect pageFrame = self.selectedPage.frame;
    [self.selectedPage removeFromSuperview];
    [self.visiblePages removeObject:self.selectedPage];
    self.selectedPage = [self loadPageAtIndex:selectedPageScrollIndex insertIntoVisibleIndex:visibleIndex];
    self.selectedPage.identityFrame = identityFrame;
    self.selectedPage.frame = pageFrame;
    self.selectedPage.alpha = 1.0;
    [self addSubview:self.selectedPage];
    
	[self setViewMode:TabPageScrollViewModeDeck animated:animated];
}

- (void)preparePage:(TabPageView *)page forMode:(TabPageScrollViewMode)mode
{
    // When a page is presented in TabPageScrollViewModePage mode, it is scaled up and is moved to a different superview. 
    // As it captures the full screen, it may be cropped to fit inside its new superview's frame. 
    // So when moving it back to TabPageScrollViewModeDeck, we restore the page's proportions to prepare it to Deck mode.  
	if (mode == TabPageScrollViewModeDeck && 
        CGAffineTransformEqualToTransform(page.transform, CGAffineTransformIdentity)) {
        page.frame = page.identityFrame;
	}
}

- (void)setViewMode:(TabPageScrollViewMode)mode animated:(BOOL)animated
{
	if (self.viewMode == mode) {
		return;
	}
	
	self.viewMode = mode;
	
	if (self.selectedPage) {
        [self preparePage:self.selectedPage forMode:mode];
    }
    
	NSInteger selectedIndex = [self indexForSelectedPage];
    
	void (^SelectBlock)(void) = (mode == TabPageScrollViewModePage)? ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        UIView *headerView = self.pageHeaderView;
        
		// move to TabPageScrollViewModePage
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willSelectPageAtIndex:selectedIndex];
		}
        
		[self.scrollView bringSubviewToFront:self.selectedPage];
		if ([self.dataSource respondsToSelector:@selector(pageScrollView:headerViewForPageAtIndex:)]) {
            UIView *altHeaderView = [self.dataSource pageScrollView:self headerViewForPageAtIndex:selectedIndex];
            [self.userHeaderView removeFromSuperview];
            [self.userHeaderView release];
            self.userHeaderView = nil;
            if (altHeaderView) {
                //use the header view initialized by the dataSource 
                self.pageHeaderView.hidden = YES; 
                self.userHeaderView = [altHeaderView retain];
                CGRect frame = self.userHeaderView.frame;
                frame.origin.y = 0;
                self.userHeaderView.frame = frame; 
                headerView = self.userHeaderView;
                [self addSubview : self.userHeaderView];
            } else {
                self.pageHeaderView.hidden = NO; 
                [self initHeaderForPageAtIndex:selectedIndex];
            }
		} else { //use the default header view
            self.pageHeaderView.hidden = NO; 
			[self initHeaderForPageAtIndex:selectedIndex]; 
		}
        
		// scale the page up to it 1:1 (identity) scale
		self.selectedPage.transform = CGAffineTransformIdentity; 
        
        // adjust the frame
        CGRect frame = self.selectedPage.frame;
		frame.origin.y = headerView.frame.size.height - self.scrollView.frame.origin.y;
        
        // store this frame for the backward animation
        self.selectedPage.identityFrame = frame; 
        
        // finally crop frame to fit inside new superview (see CompletionBlock) 
		frame.size.height = self.frame.size.height - headerView.frame.size.height;
		self.selectedPage.frame = frame;
		
		// reveal the page header view
		headerView.alpha = 1.0;
        
        // remove close button
        [self.selectedPage bringSubviewToFront:self.selectedPage.closeButton];
        self.selectedPage.closeButton.alpha = 0.0f;
        
		//remove unnecessary views
		[self.scrollViewTouch removeFromSuperview];
		[self.pageControlTouch removeFromSuperview];
	} : ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        UIView *headerView = self.userHeaderView ? self.userHeaderView : self.pageHeaderView;
        
		// move to TabPageScrollViewModeDeck
		self.pageControl.hidden = NO;
		self.pageDeckTitleLabel.hidden = NO;
		self.pageDeckSubtitleLabel.hidden = NO;
		[self initDeckTitlesForPageAtIndex:selectedIndex];
		
        // add the page back to the scrollView and transform it
        [self.scrollView addSubview:self.selectedPage];
        
		self.selectedPage.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
 		CGRect frame = self.selectedPage.frame;
        frame.origin.y = 0;
        self.selectedPage.frame = frame;
        
        // hide the page header view
        headerView.alpha = 0.0;	
        
        [self.selectedPage addSubview:self.selectedPage.closeButton];
        self.selectedPage.closeButton.alpha = 1.0f;
        [self.selectedPage bringSubviewToFront:self.selectedPage.closeButton];
        
        // notify the delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willDeselectPageAtIndex:selectedIndex];
		}		
	};
	
	void (^CompletionBlock)(BOOL) = (mode == TabPageScrollViewModePage)? ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        UIView *headerView = self.userHeaderView ? self.userHeaderView : self.pageHeaderView;
        
        // set flags
		self.pageDeckTitleLabel.hidden = YES;
		self.pageDeckSubtitleLabel.hidden = YES;
		self.pageControl.hidden = YES;
		self.scrollView.scrollEnabled = NO;
		self.selectedPage.alpha = 1.0;

		// copy self.selectedPage up in the view hierarchy, to allow touch events on its entire frame 
		self.selectedPage.frame = CGRectMake(0, headerView.frame.size.height, self.frame.size.width, self.selectedPage.frame.size.height);
		[self addSubview:self.selectedPage];

		// notify delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didSelectPageAtIndex:selectedIndex];
		}
	} : ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
		self.scrollView.scrollEnabled = YES;				
		//self.scrollView.frame = CGRectMake(0, self.scrollViewTouch.frame.origin.y, self.frame.size.width, self.scrollViewTouch.frame.size.height);
		[self addSubview:self.scrollViewTouch];
		[self addSubview: self.pageControlTouch];
        
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didDeselectPageAtIndex:selectedIndex];
		}		
	};
	
	if (animated) {
		[UIView animateWithDuration:0.3 animations:SelectBlock completion:CompletionBlock];
	} else {
		SelectBlock();
		CompletionBlock(YES);
	}
}

// *******************************************************************************************************************************

#pragma mark - PageControl Data

- (void)reloadData
{
    NSInteger numPages = 1;  
	if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
		numPages = [self.dataSource numberOfPagesInScrollView:self];
	}
	
    NSInteger selectedIndex = self.selectedPage ? [self.visiblePages indexOfObject:self.selectedPage] : NSNotFound;
    
	// reset visible pages array
	[self.visiblePages removeAllObjects];
	// remove all subviews from scrollView
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }]; 
    
	self.numberOfPages = numPages;
	
    // hide view components initially
    self.pageHeaderView.alpha = 0.0f;	
    self.pageDeckTitleLabel.hidden = YES;
    self.pageDeckSubtitleLabel.hidden = YES;
    
	if (self.numberOfPages > 0) {
		// reload visible pages
		for (int index = 0; index < self.visibleIndexes.length; index++) {
			TabPageView *page = [self loadPageAtIndex:(self.visibleIndexes.location + index) insertIntoVisibleIndex:index];
            [self addPageToScrollView:page atIndex:(self.visibleIndexes.location + index)];
		}
		
		// this will load any additional views which become visible  
		[self updateVisiblePages];
		
        // set initial alpha values for all visible pages
        [self.visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self setAlphaForPage:obj];
        }];
		
        if (selectedIndex == NSNotFound) {
            // if no page is selected, select the first page
            self.selectedPage = [self.visiblePages objectAtIndex:0];
        } else {
            // refresh the page at the selected index (it might have changed after reloading the visible pages) 
            self.selectedPage = [self.visiblePages objectAtIndex:selectedIndex];
        }
        
        // update deck title and subtitle for selected page
        NSInteger index = [self indexForSelectedPage];
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
            self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
        }
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
            self.pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
        }	
        
        // show deck-mode title/subtitle
        self.pageDeckTitleLabel.hidden = NO;
        self.pageDeckSubtitleLabel.hidden = NO;
	}
    
    // reloading the data implicitely resets the viewMode to UIPageScrollViewModeDeck. 
    // here we restore the view mode in case this is not the first time reloadData is called (i.e. if there if a self.selectedPage).   
    if (self.selectedPage && self.viewMode == TabPageScrollViewModePage) { 
        self.viewMode = TabPageScrollViewModeDeck;
        [self setViewMode:TabPageScrollViewModePage animated:NO];
    }
}

- (TabPageView *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex
{
	TabPageView *visiblePage = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
    
	if (visiblePage.reuseIdentifier) {
		NSMutableArray *reusables = [self.reusablePages objectForKey:visiblePage.reuseIdentifier];
		if (!reusables) {
			reusables = [[[NSMutableArray alloc] initWithCapacity:4] autorelease];
		}
		if (![reusables containsObject:visiblePage]) {
			[reusables addObject:visiblePage];
		}
		[self.reusablePages setObject:reusables forKey:visiblePage.reuseIdentifier];
	}
	
	// add the page to the visible pages array
	[self.visiblePages insertObject:visiblePage atIndex:visibleIndex];
    
    return visiblePage;
}

// add a page to the scroll view at a given index. No adjustments are made to existing pages offsets. 
- (void)addPageToScrollView:(TabPageView *)page atIndex:(NSInteger)index
{
    // inserting a page into the scroll view is in TabPageScrollViewModeDeck by definition (the scroll is the "deck")
    [self preparePage:page forMode:TabPageScrollViewModeDeck];
    
	// configure the page frame
    [self setFrameForPage:page atIndex:index];
    
	// add shadow (use shadowPath to improve rendering performance)
	page.layer.shadowColor = [[UIColor blackColor] CGColor];	
	page.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	page.layer.shadowOpacity = 0.3f;
    page.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:page.bounds];
    page.layer.shadowPath = path.CGPath;	
    
    // add the page to the scroller
	[self.scrollView insertSubview:page atIndex:0];
}

// inserts a page to the scroll view at a given offset by pushing existing pages forward.
- (void)insertPageInScrollView:(TabPageView *)page atIndex:(NSInteger)index animated:(BOOL)animated
{
    //hide the new page before inserting it
    page.alpha = 0.0; 
    
    // add the new page at the correct offset
	[self addPageToScrollView:page atIndex:index]; 
    
    // shift pages at or after the new page offset forward
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id existingPage, NSUInteger idx, BOOL *stop) {
        if (existingPage != page && page.frame.origin.x <= ((UIView *)existingPage).frame.origin.x) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self shiftPage:existingPage withOffset:self.scrollView.frame.size.width];
                } completion:^(BOOL finished) {
                    [self selectPageAtIndex:index animated:animated];
                }];
            } else {
                [self shiftPage:existingPage withOffset:self.scrollView.frame.size.width];
            }                
        }
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^(void) {
            [self setAlphaForPage:page];
        }];
    } else {
        [self setAlphaForPage:page];
    }
}

- (void)removePagesFromScrollView:(NSArray *)pages animated:(BOOL)animated
{
    CGFloat selectedPageOffset = NSNotFound;
    if ([pages containsObject:self.selectedPage]) {
        selectedPageOffset = self.selectedPage.frame.origin.x;
    }
    
    // remove the pages from the scrollView
    [pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // shift the remaining pages in the scrollView
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id remainingPage, NSUInteger idx, BOOL *stop) {
        NSIndexSet *removedPages = [pages indexesOfObjectsPassingTest:^BOOL(id removedPage, NSUInteger idx, BOOL *stop) {
            return ((UIView *)removedPage).frame.origin.x < ((UIView *)remainingPage).frame.origin.x;
        }]; 
        
        if (removedPages.count > 0) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self shiftPage:remainingPage withOffset:-(removedPages.count * self.scrollView.frame.size.width)];
                    //[self showCloseTabButton];
                }];
            } else {
                [self shiftPage:remainingPage withOffset:-(removedPages.count * self.scrollView.frame.size.width)];
                //[self showCloseTabButton];
            }                
        }
    }];
    
    // update the selected page if it has been removed 
    if (selectedPageOffset != NSNotFound) {
        NSInteger index = [[self.scrollView subviews] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            CGFloat delta = fabsf(((UIView *)obj).frame.origin.x - selectedPageOffset);
            return delta < 0.1;
        }];
        
        TabPageView *newSelectedPage=nil;
        if (index != NSNotFound) {
            // replace selected page with the new page which is in the same offset 
            newSelectedPage = [[self.scrollView subviews] objectAtIndex:index];
        } else {
            // replace selected page with last visible page 
            newSelectedPage = [self.visiblePages lastObject];
        }        
        NSInteger newSelectedPageIndex = [self indexForVisiblePage:newSelectedPage];
        if (newSelectedPage != self.selectedPage) {
            [self updateScrolledPage:newSelectedPage index:newSelectedPageIndex];
        }
    }
        
    // adjust self.scrollView content size
    //    CGSize newContentSize = self.scrollView.contentSize;
    //    newContentSize.width -= pages.count * self.scrollView.frame.size.width;
    //    self.scrollView.contentSize = newContentSize;
    //    
    //    // adjust page selector (control)
    //    self.pageSelector.numberOfPages -= pages.count;
}

- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index
{
    page.transform = CGAffineTransformMakeScale(0.6, 0.6);
	CGFloat contentOffset = index * self.scrollView.frame.size.width;
	CGFloat margin = (self.scrollView.frame.size.width - page.frame.size.width) / 2; 
	CGRect frame = page.frame;
	frame.origin.x = contentOffset + margin;
	frame.origin.y = 0.0;
	page.frame = frame;
}

- (void)shiftPage:(TabPageView *)page withOffset:(CGFloat)offset
{
    CGRect frame = page.frame;
    frame.origin.x += offset;
    page.frame = frame; 
    
    // also refresh the alpha of the shifted page
    [self setAlphaForPage : page];	
}

// *******************************************************************************************************************************

#pragma mark - insertion/deletion/reloading


- (void)prepareForDataUpdate:(TabPageScrollViewUpdateMethod)method withIndexSet:(NSIndexSet *)indexes
{
    // check if current mode allows data update
    if(self.viewMode == TabPageScrollViewModePage){
        // deleting pages is (currently) only supported in DECK mode.
        NSException *exception = [NSException exceptionWithName:kExceptionNameInvalidOperation reason:kExceptionReasonInvalidOperation userInfo:nil];
        [exception raise];
    }
    
    // check number of pages
    if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
        NSInteger newNumberOfPages = [self.dataSource numberOfPagesInScrollView:self];
        
        NSInteger expectedNumberOfPages;
        NSString *reason;
        switch (method) {
            case TabPageScrollViewUpdateMethodDelete:
                expectedNumberOfPages = self.numberOfPages - indexes.count;
                reason = [NSString stringWithFormat:kExceptionReasonInvalidUpdate, newNumberOfPages, self.numberOfPages, 0, indexes.count];
                break;
            case TabPageScrollViewUpdateMethodInsert:
                expectedNumberOfPages = self.numberOfPages + indexes.count;
                reason = [NSString stringWithFormat:kExceptionReasonInvalidUpdate, newNumberOfPages, self.numberOfPages, indexes.count, 0];
                break;
            case TabPageScrollViewUpdateMethodReload:
                reason = [NSString stringWithFormat:kExceptionReasonInvalidUpdate, newNumberOfPages, self.numberOfPages, 0, 0];
            default:
                expectedNumberOfPages = self.numberOfPages;
                break;
        }
        
        if (newNumberOfPages != expectedNumberOfPages) {
            NSException *exception = [NSException exceptionWithName:kExceptionNameInvalidUpdate reason:reason userInfo:nil];
            [exception raise];
        }
	}
    
    // separate the indexes into 3 sets:
    self.indexesBeforeVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx < self.visibleIndexes.location);
    }];
    
    self.indexesWithinVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx >= self.visibleIndexes.location && 
                (self.visibleIndexes.length > 0 ? idx < self.visibleIndexes.location + _visibleIndexes.length : YES));
    }];
    
    self.indexesAfterVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return ((self.visibleIndexes.length > 0 ? idx >= self.visibleIndexes.location + _visibleIndexes.length : NO));
    }];
}

- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    [self prepareForDataUpdate:TabPageScrollViewUpdateMethodInsert withIndexSet:indexes];
    
    // handle insertion of pages before the visible range. Shift pages forward.
    if (self.indexesBeforeVisibleRange.count > 0) {
        self.numberOfPages += self.indexesBeforeVisibleRange.count;
        [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id page, NSUInteger idx, BOOL *stop) {
            [self shiftPage:page withOffset:self.indexesBeforeVisibleRange.count * self.scrollView.frame.size.width];
        }];
        
        _visibleIndexes.location += self.indexesBeforeVisibleRange.count; 
        
        // update scrollView contentOffset
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x += self.indexesBeforeVisibleRange.count * self.scrollView.frame.size.width;
        self.scrollView.contentOffset = contentOffset;
        
        // refresh the page control
        [self.pageControl setCurrentPage:[self indexForSelectedPage]];
    }
    
    // handle insertion of pages within the visible range. 
    NSInteger selectedPageIndex = (self.numberOfPages > 0) ? [self indexForSelectedPage] : 0;
    self.numberOfPages += self.indexesWithinVisibleRange.count;
    [self.indexesWithinVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        TabPageView *page = [self loadPageAtIndex:idx insertIntoVisibleIndex: idx - self.visibleIndexes.location];
        [self insertPageInScrollView:page atIndex:idx animated:animated]; 
        _visibleIndexes.length++; 
        if (self.visibleIndexes.length > 3) {
            TabPageView *page = [self.visiblePages lastObject];
            [page removeFromSuperview];
            [self.visiblePages removeObject:page];
            _visibleIndexes.length--;
        }
    }];
    
    // update selected page if necessary
    if ([self.indexesWithinVisibleRange containsIndex:selectedPageIndex]) {
        [self updateScrolledPage:[self.visiblePages objectAtIndex:(selectedPageIndex - self.visibleIndexes.location)] index:selectedPageIndex];
    }
    
    // handle insertion of pages after the visible range
    if (self.indexesAfterVisibleRange.count > 0) {
        self.numberOfPages = self.numberOfPages + self.indexesAfterVisibleRange.count;
    }
}

- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    [self prepareForDataUpdate : TabPageScrollViewUpdateMethodDelete withIndexSet:indexes];
    
    // handle deletion of indexes _before_ the visible range. 
    [self.indexesBeforeVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        // 'Removing' pages which are before the visible range is a special case because we don't really have an instance of these pages. 
        // Therefore, we create pseudo-pages to be 'removed' by removePagesFromScrollView:animated:. This method shifts all pages  
        // which follow the deleted ones backwards and adjusts the contentSize of the scrollView.
        
        //TODO: solve this limitation:
        // in order to shift pages backwards and trim the content size, the WIDTH of each deleted page needs to be known. 
        // We don't have an instance of the deleted pages and we cannot ask the data source to provide them because they've already been deleted. As a temp solution we take the default page width of 320. 
        // This assumption may be wrong if the data source uses anotehr page width or alternatively varying page widths.   
        UIView *pseudoPage = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
        [self setFrameForPage:pseudoPage atIndex:idx];
        [self.deletedPages addObject:pseudoPage];
        _visibleIndexes.location--;
    }];
    if (self.deletedPages.count > 0) {
        // removePagesFromScrollView:animated shifts all pages which follow the deleted pages backwards, and trims the scrollView contentSize respectively. As a result UIScrollView may adjust its contentOffset (if it is larger than the new contentSize). 
        // Here we store the oldOffset to make sure we adjust it by exactly the number of pages deleted. 
        CGFloat oldOffset = self.scrollView.contentOffset.x;
        // set the new number of pages 
        self.numberOfPages = self.numberOfPages - self.deletedPages.count;
        //self.numberOfPages -= self.deletedPages.count;
        
        [self removePagesFromScrollView:self.deletedPages animated:NO]; //never animate removal of non-visible pages
        CGFloat newOffset = oldOffset - (self.deletedPages.count * self.scrollView.frame.size.width);
        self.scrollView.contentOffset = CGPointMake(newOffset, self.scrollView.contentOffset.y);
        [self.deletedPages removeAllObjects];
    }
    
    // handle deletion of pages _within_ and _after_ the visible range. 
    self.numberOfFreshPages = 0;
    NSInteger numPagesAfterDeletion = self.numberOfPages -= self.indexesWithinVisibleRange.count + self.indexesAfterVisibleRange.count; 
    [self.indexesWithinVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        // get the deleted page 
        [self.deletedPages addObject: [self pageAtIndex:idx]];
        
        // load new pages to replace the deleted ones in the visible range 
        if (self.visibleIndexes.location + self.visibleIndexes.length <= numPagesAfterDeletion){
            // more pages are available after the visible range. Load a new page from the data source
            NSInteger newPageIndex = self.visibleIndexes.location + self.visibleIndexes.length - self.deletedPages.count;
            TabPageView *page = [self loadPageAtIndex:newPageIndex insertIntoVisibleIndex:self.visibleIndexes.length];            
            // insert the new page after the current visible pages. When the visible pages will be removed, 
            // in removePagesFromScrollView:animated:, these new page/s will enter the visible rectangle of the scrollView. 
            [self addPageToScrollView:page atIndex:(newPageIndex + self.indexesWithinVisibleRange.count)];
            self.numberOfFreshPages++;
        }
    }];
    
    // update the visible range if necessary
    NSInteger deleteCount = self.deletedPages.count;
    if (deleteCount > 0 && self.numberOfFreshPages < deleteCount) {
        // Not enough fresh pages were loaded to fill in for the deleted pages in the visible range. 
        // This can only be a result of hitting the end of the page scroller. 
        // Adjust the visible range to show the end of the scroll (ideally the last 2 pages, or less). 
        NSInteger newLength = self.visibleIndexes.length - deleteCount + self.numberOfFreshPages;
        if (newLength >= 2) {
            _visibleIndexes.length = newLength;
        } else {
            if(self.visibleIndexes.location==0){
                _visibleIndexes.length = newLength;
            } else {
                NSInteger delta = MIN(2-newLength, self.visibleIndexes.location);
                _visibleIndexes.length = newLength + delta;
                _visibleIndexes.location -= delta; 
                
                //load 'delta' pages from before the visible range to replace deleted pages
                for (int i=0; i<delta; i++) {
                    TabPageView *page = [self loadPageAtIndex:self.visibleIndexes.location + i insertIntoVisibleIndex:i];    
                    [self addPageToScrollView:page atIndex:self.visibleIndexes.location + i]; 
                }
            }
        }               
    }
    
    
    //update number of pages.  
    self.numberOfPages = numPagesAfterDeletion;
    // remove the pages marked for deletion from visiblePages 
    [self.visiblePages removeObjectsInArray:self.deletedPages];
    // ...and from the scrollView
    [self removePagesFromScrollView:self.deletedPages animated:animated];
    
    
    [self.deletedPages removeAllObjects];
    
    // for indexes after the visible range, only adjust the scrollView contentSize
    //    if (self.indexesAfterVisibleRange.count > 0) {
    //        self.scrollView.contentSize = CGSizeMake(self.numberOfPages * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);            
    //        self.pageControl.numberOfPages = self.numberOfPages;      
    //    }
    
}

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes
{
    [self prepareForDataUpdate : TabPageScrollViewUpdateMethodReload withIndexSet:indexes];
    
    // only reload pages within the visible range
    [self.indexesWithinVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        TabPageView *page = [self pageAtIndex:idx];
        [self.visiblePages removeObject : page]; // remove from visiblePages
        [page removeFromSuperview];          // remove from scrollView
        
        page = [self loadPageAtIndex:idx insertIntoVisibleIndex: idx - self.visibleIndexes.location];
        [self addPageToScrollView:page atIndex:idx];
    }];        
}

- (void)setNumberOfPages:(NSInteger)number 
{
    _numberOfPages = number; 
    self.scrollView.contentSize = CGSizeMake(_numberOfPages * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);            
    self.pageControl.numberOfPages = _numberOfPages;      
}

// *******************************************************************************************************************************

#pragma mark - UIScrollViewDelegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageScrollViewWillBeginDragging:)]) {
        [self.delegate pageScrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(pageScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate pageScrollViewDidEndDragging:self willDecelerate:decelerate];
    }
    
    if (self.isPendingScrolledPageUpdateNotification) {
        if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
            NSInteger selectedIndex = [self.visiblePages indexOfObject:self.selectedPage];
            [self.delegate pageScrollView:self didScrollToPage:self.selectedPage atIndex:selectedIndex];
        }
        self.isPendingScrolledPageUpdateNotification = NO;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageScrollViewWillBeginDecelerating:)]) {
        [self.delegate pageScrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageScrollViewDidEndDecelerating:)]) {
        [self.delegate pageScrollViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// update the visible pages
	[self updateVisiblePages];
	
	// adjust alpha for all visible pages
	[self.visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self setAlphaForPage:obj];		
	}];
	
	CGFloat delta = scrollView.contentOffset.x - self.selectedPage.frame.origin.x;
	BOOL toggleNextItem = (fabs(delta) > scrollView.frame.size.width / 2);
	if (toggleNextItem && self.visiblePages.count > 1) {
		
		NSInteger selectedIndex = [self.visiblePages indexOfObject:self.selectedPage];
		BOOL neighborExists = ((delta < 0 && selectedIndex > 0) || (delta > 0 && selectedIndex < self.visiblePages.count - 1));
		
		if (neighborExists) {
			
			NSInteger neighborPageVisibleIndex = [self.visiblePages indexOfObject:self.selectedPage] + (delta > 0 ? 1 : -1);
			TabPageView *neighborPage = [self.visiblePages objectAtIndex:neighborPageVisibleIndex];
			NSInteger neighborIndex = self.visibleIndexes.location + neighborPageVisibleIndex;
            
			[self updateScrolledPage:neighborPage index:neighborIndex];
		}
	}
}

- (void)updateScrolledPage:(TabPageView *)page index:(NSInteger)index
{
    if (!page) {
        self.pageDeckTitleLabel.text = @"";
        self.pageDeckSubtitleLabel.text = @"";
        self.selectedPage = nil;
    } else {
        // notify delegate
        if ([self.delegate respondsToSelector:@selector(pageScrollView:willScrollToPage:atIndex:)]) {
            [self.delegate pageScrollView:self willScrollToPage:page atIndex:index];
        }
        
        // update title and subtitle
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
            self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
        }
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
            self.pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
        }
        
        // set the page selector (page control)
        [self.pageControl setCurrentPage:index];
        
        // set selected page
        self.selectedPage = page;
        //	NSLog(@"selectedPage: 0x%x (index %d)", page, index );
        
        if (self.scrollView.dragging) {
            self.isPendingScrolledPageUpdateNotification = YES;
        } else {
            // notify delegate again
            if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
                [self.delegate pageScrollView:self didScrollToPage:page atIndex:index];
            }
            self.isPendingScrolledPageUpdateNotification = NO;
        }	       
    }
}

- (void)updateVisiblePages
{
	CGFloat pageWidth = self.scrollView.frame.size.width;
    
	//get x origin of left- and right-most pages in self.scrollView's superview coordinate space (i.e. self)  
	CGFloat leftViewOriginX = self.scrollView.frame.origin.x - self.scrollView.contentOffset.x + (self.visibleIndexes.location * pageWidth);
	CGFloat rightViewOriginX = self.scrollView.frame.origin.x - self.scrollView.contentOffset.x + (self.visibleIndexes.location+self.visibleIndexes.length - 1) * pageWidth;
	
	if (leftViewOriginX > 0) {
		//new page is entering the visible range from the left
		if (self.visibleIndexes.location > 0) { //is it not the first page?
			_visibleIndexes.length += 1;
			_visibleIndexes.location -= 1;
			TabPageView *page = [self loadPageAtIndex:self.visibleIndexes.location insertIntoVisibleIndex:0];
            // add the page to the scroll view (to make it actually visible)
            [self addPageToScrollView:page atIndex:self.visibleIndexes.location];
            
		}
	}
	else if(leftViewOriginX < -pageWidth){
		//left page is exiting the visible range
		UIView *page = [self.visiblePages objectAtIndex:0];
        [self.visiblePages removeObject:page];
        [page removeFromSuperview]; //remove from the scroll view
		_visibleIndexes.location += 1;
		_visibleIndexes.length -= 1;
	}
	if (rightViewOriginX > self.frame.size.width) {
		//right page is exiting the visible range
		UIView *page = [self.visiblePages lastObject];
        [self.visiblePages removeObject:page];
        [page removeFromSuperview]; //remove from the scroll view
		_visibleIndexes.length -= 1;
	}
	else if(rightViewOriginX + pageWidth < self.frame.size.width){
		//new page is entering the visible range from the right
		if (self.visibleIndexes.location + self.visibleIndexes.length < self.numberOfPages) { //is is not the last page?
			_visibleIndexes.length += 1;
            NSInteger index = self.visibleIndexes.location + self.visibleIndexes.length - 1;
			TabPageView *page = [self loadPageAtIndex:index insertIntoVisibleIndex:self.visibleIndexes.length - 1];
            [self addPageToScrollView:page atIndex:index];
            
		}
	}
}

- (void)setAlphaForPage:(TabPageView *)page
{
	CGFloat delta = self.scrollView.contentOffset.x - page.frame.origin.x;
	CGFloat step = self.frame.size.width;
	CGFloat alpha = 1.0 - fabs(delta/step);

	if (alpha > 0.95)
        alpha = 1.0;
    
    page.alpha = alpha;
    
	CGFloat alphaButton = 1.0 - fabs(delta/step * 1.5);
    page.closeButton.alpha = alphaButton;
}

- (void)initHeaderForPageAtIndex:(NSInteger)index
{
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		UILabel *titleLabel = (UILabel*)[self.pageHeaderView viewWithTag:1];
		titleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
	
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {		
		UILabel *subtitleLabel = (UILabel*)[self.pageHeaderView viewWithTag:2];
		subtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
}

- (void)initDeckTitlesForPageAtIndex:(NSInteger)index
{
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
    
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
		self.pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
}

// Used by the delegate to acquire an already allocated page, instead of allocating a new one
- (TabPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier
{
	TabPageView *reusablePage = nil;
    
	NSArray *reusables = [self.reusablePages objectForKey:identifier];
	if (reusables){
		NSEnumerator *enumerator = [reusables objectEnumerator];
		while ((reusablePage = [enumerator nextObject])) {
			if(![self.visiblePages containsObject:reusablePage]){
				[reusablePage prepareForReuse];
				break;
			}
		}
	}
    
	return reusablePage;
}

// *******************************************************************************************************************************

#pragma mark - Handling Touches


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL shouldReceive = self.viewMode == TabPageScrollViewModeDeck && !self.scrollView.decelerating && !self.scrollView.dragging;
    
	return shouldReceive;	
}

- (void)handleTapGestureFrom:(UITapGestureRecognizer *)recognizer 
{
    if (!self.selectedPage)
        return;
    
	NSInteger selectedIndex = [self indexForSelectedPage];
	
	[self selectPageAtIndex:selectedIndex animated:YES];
}

// *******************************************************************************************************************************

#pragma mark - Actions


- (void)didChangePageValue:(id)sender
{
	NSInteger selectedIndex = [self indexForSelectedPage];
	if(self.pageControl.currentPage != selectedIndex){
		//set pageScroller
		selectedIndex = self.pageControl.currentPage;
		//self.userInitiatedScroll = NO;		
		[self scrollToPageAtIndex:selectedIndex animated:YES];			
	}
}

@end
