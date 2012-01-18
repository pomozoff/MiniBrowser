//
//  PadTabPageScrollView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "PadTabPageScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface PadTabPageScrollView()

@property (nonatomic, retain) TabPageView *selectedPage;

@property (nonatomic, assign) NSInteger numberOfPages;

- (void)reloadData; 
- (TabPageView *)loadPageAtIndex:(NSInteger)index;
- (void)setViewMode:(TabPageScrollViewMode)mode animated:(BOOL)animated;
- (void)initHeaderForPageAtIndex:(NSInteger)index;
- (void)initDeckTitlesForPageAtIndex:(NSInteger)index;
- (void)setOriginForPage:(UIView *)page atIndex:(NSInteger)index;
- (void)addPageToDeck:(TabPageView *)page atIndex:(NSInteger)index;

@end

@implementation PadTabPageScrollView

@synthesize pageDeckBackgroundView = _pageDeckBackgroundView;
@synthesize pageHeaderView = _pageHeaderView;

@synthesize selectedPage = _selectedPage;

@synthesize numberOfPages = _numberOfPages;

@synthesize deletedPages = _deletedPages;
@synthesize visiblePages = _visiblePages; // array of created tabs
@synthesize reusablePages = _reusablePages;

// ******************************************************************************************************************************

#pragma mark - Properites initialization


- (NSMutableArray *)deletedPages
{
    if (!_deletedPages) {
        _deletedPages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _deletedPages;
}

- (NSMutableArray *)visiblePages
{
    if (!_visiblePages) {
        _visiblePages = [[NSMutableArray alloc] initWithCapacity:MAX_TABS_COUNT];
    }
    
    return _visiblePages;
}

- (NSMutableDictionary *)reusablePages
{
    if (!_reusablePages) {
        _reusablePages = [[NSMutableDictionary alloc] initWithCapacity:REUSABLE_PAGES_COUNT_IPAD];
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
	UIColor *topColor = [UIColor colorWithRed:0.57 green:0.63 blue:0.68 alpha:1.0];    // light blue-gray
	UIColor *bottomColor = [UIColor colorWithRed:0.31 green:0.41 blue:0.48 alpha:1.0]; // dark blue-gray
	glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    [self.pageDeckBackgroundView.layer insertSublayer:glayer atIndex:0];

	// default number of pages 
	self.numberOfPages = 1;
    
	[self reloadData];
}

- (void)freeOutlets
{
    self.pageDeckBackgroundView = nil;
    self.pageHeaderView = nil;
}

- (void)dealloc
{
    [self freeOutlets];
    
    self.selectedPage = nil;
    
    [super dealloc];
}

// *******************************************************************************************************************************

#pragma mark - Handling Touches


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL shouldReceive = self.viewMode == TabPageScrollViewModeDeck;
    
	return shouldReceive;	
}

- (void)handleTapGestureFrom:(UITapGestureRecognizer *)recognizer 
{
    CGPoint tapPoint = [recognizer locationInView:self.pageDeckBackgroundView];
    
    for (TabPageView *page in self.visiblePages) {
        CGRect closeButtonFrameScaled = page.closeButton.frame;
        closeButtonFrameScaled.size.width *= page.transform.a;
        closeButtonFrameScaled.size.height *= page.transform.d;

        closeButtonFrameScaled.origin.x *= page.transform.a;
        closeButtonFrameScaled.origin.y *= page.transform.d;
        closeButtonFrameScaled.origin.x += page.frame.origin.x;
        closeButtonFrameScaled.origin.y += page.frame.origin.y;
        
        NSInteger index = [self.visiblePages indexOfObject:page];
        
        NSUInteger subviewIndex = [page.subviews indexOfObject:page.closeButton];
        if (subviewIndex != NSNotFound && CGRectContainsPoint(closeButtonFrameScaled, tapPoint)) {
            if (index != NSNotFound) {
                [self.delegate closePageAtIndex:index];
            }
            break;
        } else if (CGRectContainsPoint(page.frame, tapPoint)) {
            NSInteger selectedIndex = [self.visiblePages indexOfObject:page];
            [self selectPageAtIndex:selectedIndex animated:YES];
            break;
        }
    }
    
/*
    if (!self.selectedPage)
        return;
    
	NSInteger selectedIndex = [self indexForSelectedPage];
    CGPoint tapPoint = [recognizer locationInView:self.selectedPage.closeButton];
    
	if ([self.selectedPage.subviews indexOfObject:self.selectedPage.closeButton] != NSNotFound && [self.selectedPage.closeButton pointInside:tapPoint withEvent:nil]) {
        [self.delegate closeCurrentPage];
	} else {
        [self selectPageAtIndex:selectedIndex animated:YES];
    }
    */
}

// *******************************************************************************************************************************

#pragma mark - Info


- (TabPageView *)pageAtIndex:(NSInteger)index            // returns nil if page is not visible or the index is out of range
{
	if (index == NSNotFound || index >= self.visiblePages.count) {
		return nil;
	}
    
	return [self.visiblePages objectAtIndex:index];
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
    return index;
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    // ignore if there are no pages or index is invalid
    if (index == NSNotFound || self.numberOfPages == 0) {
        return;
    }
    
	if (index != [self indexForSelectedPage]) {
        // reload the data for the new indexes
        [self reloadData];
        
        // update self.selectedPage
        self.selectedPage = [self.visiblePages objectAtIndex:index];
        //self.closePageTouch.receiver = self.selectedPage.closeButton;
	}
    
	[self setViewMode:TabPageScrollViewModePage animated:animated];
    
    for (TabPageView *page in self.visiblePages) {
        if (page != self.selectedPage) {
            [page removeFromSuperview];
        }
    }
}

- (void)deselectPageAnimated:(BOOL)animated
{
    // ignore if there are no pages or no self.selectedPage
    if (!self.selectedPage || self.numberOfPages == 0) {
        return;
    }
    
	[self setViewMode:TabPageScrollViewModeDeck animated:animated];
    
    for (TabPageView *page in self.visiblePages) {
        NSUInteger index = [self.visiblePages indexOfObject:page];
        [self loadPageAtIndex:index];

        if (page != self.selectedPage) {
            [self addPageToDeck:page atIndex:index];
        }
    }

    /*
    // Before moving back to DECK mode, refresh the selected page
    NSInteger index = [self indexForSelectedPage];
    CGRect identityFrame = self.selectedPage.identityFrame;
    CGRect pageFrame = self.selectedPage.frame;
    [self.selectedPage removeFromSuperview];
    self.selectedPage = [self loadPageAtIndex:index];
    self.selectedPage.identityFrame = identityFrame;
    self.selectedPage.frame = pageFrame;
    self.selectedPage.alpha = 1.0;
    [self addSubview:self.selectedPage];
    */
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
	
	if (self.selectedPage) {
        [self preparePage:self.selectedPage forMode:mode];
    }
    
	NSInteger selectedIndex = [self indexForSelectedPage];
    
	void (^SelectBlock)(void) = (mode == TabPageScrollViewModePage) ? ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
		// move to TabPageScrollViewModePage
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willSelectPageAtIndex:selectedIndex];
		}
        
        self.pageHeaderView.hidden = NO; 
        [self initHeaderForPageAtIndex:selectedIndex]; 
        
		// scale the page up to it 1:1 (identity) scale
		self.selectedPage.transform = CGAffineTransformIdentity; 
        
        // adjust the frame
        CGRect frame = self.selectedPage.frame;
        frame.origin.x = 0;
		frame.origin.y = self.pageHeaderView.frame.size.height;
        
        // store this frame for the backward animation
        self.selectedPage.identityFrame = frame; 
        
        // finally crop frame to fit inside new superview (see CompletionBlock) 
		frame.size.height -= self.pageHeaderView.frame.size.height;
		self.selectedPage.frame = frame;
		
		// reveal the page header view
		self.pageHeaderView.alpha = 1.0f;
        
        // hide close button
        self.selectedPage.closeButton.alpha = 0.0f;
        
		//remove unnecessary views
        /*
        NSInteger pagesCount = [self.dataSource numberOfPagesInScrollView:self];
        for (NSInteger currentIndex = 0; currentIndex < pagesCount; pagesCount++) {
            TabPageView *currentPage = [self.dataSource pageScrollView:self viewForPageAtIndex:currentIndex];
            [currentPage removeFromSuperview];
        }
        */
        //[self.closePageTouch removeFromSuperview];
	} : ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
		// move to TabPageScrollViewModeDeck
		//self.pageDeckTitleLabel.hidden = NO;
		[self initDeckTitlesForPageAtIndex:selectedIndex];

		self.selectedPage.transform = CGAffineTransformMakeScale(TRANSFORM_PAGE_SCALE, TRANSFORM_PAGE_SCALE);
        [self setOriginForPage:self.selectedPage atIndex:selectedIndex];
        
        // display close button
        self.selectedPage.closeButton.alpha = 1.0f;
        
        self.pageHeaderView.alpha = 0.0f;
        
        // notify the delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willDeselectPageAtIndex:selectedIndex];
		}
	};
	
	void (^CompletionBlock)(BOOL) = (mode == TabPageScrollViewModePage)? ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        // set flags
		//self.pageDeckTitleLabel.hidden = YES;
		self.selectedPage.alpha = 1.0f;
        
		// copy self.selectedPage up in the view hierarchy, to allow touch events on its entire frame 
		self.selectedPage.frame = CGRectMake(0.0f, self.pageHeaderView.frame.size.height, self.frame.size.width, self.selectedPage.frame.size.height);
		[self addSubview:self.selectedPage];
        
        self.viewMode = mode;
        
		// notify delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didSelectPageAtIndex:selectedIndex];
		}
	} : ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        /*
        if ([self.selectedPage.subviews indexOfObject:self.selectedPage.closeButton] != NSNotFound) {
            [self addSubview:self.closePageTouch];
        }
        */
        
        self.viewMode = mode;
        
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didDeselectPageAtIndex:selectedIndex];
		}		
	};
	
	if (animated) {
		[UIView animateWithDuration:0.3f animations:SelectBlock completion:CompletionBlock];
	} else {
		SelectBlock();
		CompletionBlock(YES);
	}
}

// *******************************************************************************************************************************

#pragma mark - PageControl Data


- (void)updateHeaderForPageWithIndex:(NSInteger)index
{
    /*
    if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
        self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
    }
    */
}

- (void)updateScrolledPage:(TabPageView *)page index:(NSInteger)index
{
    if (!page) {
        self.selectedPage = nil;
    } else {
        // notify delegate
        if ([self.delegate respondsToSelector:@selector(pageScrollView:willScrollToPage:atIndex:)]) {
            [self.delegate pageScrollView:self willScrollToPage:page atIndex:index];
        }
        
        // set selected page
        self.selectedPage = page;
        
        // notify delegate again
        if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
            [self.delegate pageScrollView:self didScrollToPage:page atIndex:index];
        }
        
        [self updateHeaderForPageWithIndex:index];
    }
}

- (void)updateHeaderForPage:(TabPageView *)pageView withIndex:(NSInteger)index
{
    if ([self.selectedPage isEqual:pageView]) {
        [self updateHeaderForPageWithIndex:index];
    }
}

- (void)setOriginForPage:(UIView *)page atIndex:(NSInteger)index
{
    page.transform = CGAffineTransformMakeScale(TRANSFORM_PAGE_SCALE, TRANSFORM_PAGE_SCALE);
    
	CGRect pageFrame = page.frame;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat marginX = (appFrame.size.width - TABS_COUNT_IN_ROW * pageFrame.size.width) / (TABS_COUNT_IN_ROW + 1);
    CGFloat marginY = (appFrame.size.height - TABS_COUNT_IN_COLUMN * pageFrame.size.height) / (TABS_COUNT_IN_COLUMN + 1);
    
    NSInteger yOffset = ceil(index / TABS_COUNT_IN_ROW);
    NSInteger xOffset = index - yOffset * TABS_COUNT_IN_ROW;
    
	pageFrame.origin.x = marginX + (pageFrame.size.width  + marginX) * xOffset;
	pageFrame.origin.y = marginY + (pageFrame.size.height + marginY) * yOffset;
    
	page.frame = pageFrame;
}

- (void)shiftPage:(TabPageView *)page withOffset:(CGFloat)offset
{
    CGRect frame = page.frame;
    frame.origin.x += offset;
    page.frame = frame; 
    
    // also refresh the alpha of the shifted page
    //[self setAlphaForPage:page];	
}

// add a page to the scroll view at a given index. No adjustments are made to existing pages offsets. 
- (void)addPageToDeck:(TabPageView *)page atIndex:(NSInteger)index
{
    // inserting a page into the scroll view is in TabPageScrollViewModeDeck by definition (the scroll is the "deck")
    [self preparePage:page forMode:TabPageScrollViewModeDeck];
    
	// configure the page frame
    [self setOriginForPage:page atIndex:index];
    
	// add shadow (use shadowPath to improve rendering performance)
	page.layer.shadowColor = [[UIColor blackColor] CGColor];	
	page.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	page.layer.shadowOpacity = 0.3f;
    page.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:page.bounds];
    page.layer.shadowPath = path.CGPath;	
    
    // add the page to the scroller
    if (page == self.selectedPage) {
        [self addSubview:page];
    } else {
        [self insertSubview:page belowSubview:self.selectedPage];
    }
}

- (void)reloadData
{
    NSInteger numPages = 1;  
	if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
		numPages = [self.dataSource numberOfPagesInScrollView:self];
	}
	self.numberOfPages = numPages;
	
    for (TabPageView *page in self.visiblePages) {
        [page removeFromSuperview];
    }
    
	// reset visible pages array
	[self.visiblePages removeAllObjects];

	// remove all subviews from scrollView
    /*
    [self.pageDeckBackgroundView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    */
    
    // hide view components initially
    self.pageHeaderView.alpha = 0.0f;	

	if (self.numberOfPages > 0) {
		// reload visible pages
		for (int index = 0; index < self.numberOfPages; index++) {
			TabPageView *page = [self loadPageAtIndex:index];
            [self addPageToDeck:page atIndex:index];
		}
        
        /*
		// this will load any additional views which become visible  
		[self updateVisiblePages];
		
        // set initial alpha values for all visible pages
        [self.visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self setAlphaForPage:obj];
        }];
		*/
        
        NSInteger selectedIndex = self.selectedPage ? [self.visiblePages indexOfObject:self.selectedPage] : NSNotFound;
        if (selectedIndex == NSNotFound) {
            // if no page is selected, select the first page
            self.selectedPage = [self.visiblePages objectAtIndex:0];
        } else {
            // refresh the page at the selected index (it might have changed after reloading the visible pages) 
            self.selectedPage = [self.visiblePages objectAtIndex:selectedIndex];
        }
        
        // IMPORTANT
        /*
        self.closePageTouch.receiver = self.selectedPage.closeButton;
        
        // update deck title and subtitle for selected page
        NSInteger index = [self indexForSelectedPage];
        [self updateHeaderForPageWithIndex:index];
        */
        
        /*
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
            self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
        }
        if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
            self.pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
        }
        
        // show deck-mode title/subtitle
        self.pageDeckTitleLabel.hidden = NO;
        */
	}
    
    // reloading the data implicitely resets the viewMode to UIPageScrollViewModeDeck. 
    // here we restore the view mode in case this is not the first time reloadData is called (i.e. if there if a self.selectedPage).   
    if (self.selectedPage && self.viewMode == TabPageScrollViewModePage) { 
        self.viewMode = TabPageScrollViewModeDeck;
        [self setViewMode:TabPageScrollViewModePage animated:NO];
    }
}

- (TabPageView *)loadPageAtIndex:(NSInteger)index
{
    TabPageView *visiblePage = nil;
        
    if (index < self.visiblePages.count) {
        visiblePage = [self.visiblePages objectAtIndex:index];
    } else {
        visiblePage = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
        
        if (visiblePage.reuseIdentifier) {
            NSMutableArray *reusables = [self.reusablePages objectForKey:visiblePage.reuseIdentifier];
            if (!reusables) {
                reusables = [[[NSMutableArray alloc] initWithCapacity:REUSABLE_PAGES_COUNT_IPAD] autorelease];
            }
            if (![reusables containsObject:visiblePage]) {
                [reusables addObject:visiblePage];
            }
            [self.reusablePages setObject:reusables forKey:visiblePage.reuseIdentifier];
        }
        
        // set tap gesture recognizer for page selection
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureFrom:)];
        [visiblePage addGestureRecognizer:recognizer];
        recognizer.delegate = self;
        [recognizer release];
        
        CGRect frame = visiblePage.frame;
		frame.origin.y = self.pageHeaderView.frame.size.height;
        visiblePage.identityFrame = frame; 
		frame.size.height -= self.pageHeaderView.frame.size.height;
		visiblePage.frame = frame;
        
        // insert the page to the visible pages array before new-tab-button if it exists
        if ([self.visiblePages indexOfObject:visiblePage] == NSNotFound) {
            [self.visiblePages addObject:visiblePage];
        }
    }
     
    return visiblePage;
}

- (void)removePagesFromScrollView:(NSArray *)pages animated:(BOOL)animated
{
    /*
    // remember selected page's frame
    CGFloat selectedPageOffset = NSNotFound;
    if ([pages containsObject:self.selectedPage]) {
        selectedPageOffset = self.selectedPage.frame.origin.x;
    }
    */
    
    // remove the pages from the scrollView
    [pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // shift the remaining pages in the view
    if (pages.count > 0) {
        [self.visiblePages enumerateObjectsUsingBlock:^(TabPageView *remainingPage, NSUInteger index, BOOL *stop) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self setOriginForPage:remainingPage atIndex:index];
                }];
            } else {
                [self setOriginForPage:remainingPage atIndex:index];
            }                
        }];
}
    
    // shift the remaining pages in the scrollView
    /*
    [self.visiblePages enumerateObjectsUsingBlock:^(id remainingPage, NSUInteger idx, BOOL *stop) {
        NSIndexSet *removedPages = [pages indexesOfObjectsPassingTest:^BOOL(id removedPage, NSUInteger idx, BOOL *stop) {
            return ((UIView *)removedPage).frame.origin.x < ((UIView *)remainingPage).frame.origin.x;
        }]; 
        
        if (removedPages.count > 0) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self shiftPage:remainingPage withOffset:-(removedPages.count)];
                    //[self showCloseTabButton];
                }];
            } else {
                [self shiftPage:remainingPage withOffset:-(removedPages.count)];
                //[self showCloseTabButton];
            }                
        }
    }];
    
    // update the selected page if it has been removed 
    if (selectedPageOffset != NSNotFound) {
        NSInteger index = [self.visiblePages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            CGFloat delta = fabsf(((UIView *)obj).frame.origin.x - selectedPageOffset);
            return delta < 0.1;
        }];
        
        TabPageView *newSelectedPage = nil;
        if (index != NSNotFound) {
            // replace selected page with the new page which is in the same offset 
            newSelectedPage = [self.visiblePages objectAtIndex:index];
        } else {
            // replace selected page with last visible page 
            newSelectedPage = [self.visiblePages lastObject];
        }
        
        NSInteger newSelectedPageIndex = [self indexForVisiblePage:newSelectedPage];
        if (newSelectedPage != self.selectedPage) {
            [self updateScrolledPage:newSelectedPage index:newSelectedPageIndex];
        }
    }
    */
}

// *******************************************************************************************************************************

#pragma mark - insertion/deletion/reloading


- (void)prepareForDataUpdate:(TabPageScrollViewUpdateMethod)method withIndexSet:(NSIndexSet *)indexes
{
    // check if current mode allows data update
    if (self.viewMode == TabPageScrollViewModePage) {
        // deleting pages is (currently) only supported in DECK mode.
        NSException *exception = [NSException exceptionWithName:kExceptionNameInvalidOperation
                                                         reason:kExceptionReasonInvalidOperation
                                                       userInfo:nil];
        [exception raise];
    }
    
    // check number of pages
    if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
        NSInteger newNumberOfPages = [self.dataSource numberOfPagesInScrollView:self];
        
        NSInteger expectedNumberOfPages = 0;
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
}

- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    [self prepareForDataUpdate:TabPageScrollViewUpdateMethodInsert withIndexSet:indexes];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        TabPageView *pageView = [self loadPageAtIndex:index];

        if (self.viewMode == TabPageScrollViewModeDeck && pageView.isNewTabButton) {
            [self addPageToDeck:pageView atIndex:index];
        }
        
        // update selected page if necessary
        if (animated) {
            [self updateScrolledPage:[self.visiblePages objectAtIndex:index] index:index];
        }
    }];
    
    self.numberOfPages += indexes.count;

    /*
    NSInteger selectedPageIndex = (self.numberOfPages > 0) ? [self indexForSelectedPage] : 0;
    [self loadPageAtIndex:selectedPageIndex];
    
    // update selected page if necessary
    [self updateScrolledPage:[self.visiblePages objectAtIndex:selectedPageIndex] index:selectedPageIndex];
     */
}

- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    [self prepareForDataUpdate:TabPageScrollViewUpdateMethodDelete withIndexSet:indexes];
    
    // handle deletion of pages _within_ and _after_ the visible range. 
    NSInteger numPagesAfterDeletion = self.numberOfPages - indexes.count;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        // get the deleted page 
        [self.deletedPages addObject:[self pageAtIndex:index]];
    }];
    
    //update number of pages.  
    self.numberOfPages = numPagesAfterDeletion;
    // remove the pages marked for deletion from visiblePages 
    [self.visiblePages removeObjectsInArray:self.deletedPages];
    // ...and from the scrollView
    [self removePagesFromScrollView:self.deletedPages animated:animated];
    
    [self.deletedPages removeAllObjects];
}

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes
{
    [self prepareForDataUpdate:TabPageScrollViewUpdateMethodReload withIndexSet:indexes];
    
    // only reload pages within the visible range
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        TabPageView *page = [self pageAtIndex:index];
        [self.visiblePages removeObject:page]; // remove from visiblePages
        [page removeFromSuperview];            // remove from scrollView
        
        page = [self loadPageAtIndex:index];
        [self addPageToDeck:page atIndex:index];
    }];        
}

// *******************************************************************************************************************************

#pragma mark - UIScrollViewDelegate


- (void)initHeaderForPageAtIndex:(NSInteger)index
{
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		UILabel *titleLabel = (UILabel *)[self.pageHeaderView viewWithTag:1];
		titleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
	
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {		
		UILabel *subtitleLabel = (UILabel *)[self.pageHeaderView viewWithTag:2];
		subtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
}

- (void)initDeckTitlesForPageAtIndex:(NSInteger)index
{
    /*
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
    */
}

@end
