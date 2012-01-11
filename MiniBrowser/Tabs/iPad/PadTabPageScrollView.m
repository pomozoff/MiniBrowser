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
@property (nonatomic, retain) NSMutableArray *visiblePages;

- (void)reloadData; 
- (void)setViewMode:(TabPageScrollViewMode)mode animated:(BOOL)animated;
- (void)initHeaderForPageAtIndex:(NSInteger)index;
- (void)initDeckTitlesForPageAtIndex:(NSInteger)index;
- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index;

@end

@implementation PadTabPageScrollView

@synthesize pageDeckBackgroundView = _pageDeckBackgroundView;
@synthesize pageHeaderView = _pageHeaderView;

@synthesize selectedPage = _selectedPage;

@synthesize numberOfPages = _numberOfPages;
@synthesize visiblePages = _visiblePages;

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
    
    self.visiblePages = nil;
    self.selectedPage = nil;
    
    [super dealloc];
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
}

- (void)deselectPageAnimated:(BOOL)animated
{
    // ignore if there are no pages or no self.selectedPage
    if (!self.selectedPage || self.numberOfPages == 0) {
        return;
    }
    
    // Before moving back to DECK mode, refresh the selected page
    NSInteger index = [self indexForSelectedPage];
    CGRect identityFrame = self.selectedPage.identityFrame;
    CGRect pageFrame = self.selectedPage.frame;
    [self.selectedPage removeFromSuperview];
    self.selectedPage = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
    self.selectedPage.identityFrame = identityFrame;
    self.selectedPage.frame = pageFrame;
    self.selectedPage.alpha = 1.0;
    [self addSubview:self.selectedPage];
    
    //self.closePageTouch.receiver = self.selectedPage.closeButton;
    
	[self setViewMode:TabPageScrollViewModeDeck animated:animated];
}

- (void)preparePage:(TabPageView *)page forMode:(TabPageScrollViewMode)mode
{
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
    
	void (^SelectBlock)(void) = (mode == TabPageScrollViewModePage) ? ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        UIView *headerView = self.pageHeaderView;
        
		// move to TabPageScrollViewModePage
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willSelectPageAtIndex:selectedIndex];
		}
        
        self.pageHeaderView.hidden = NO; 
        [self initHeaderForPageAtIndex:selectedIndex]; 
        
		// scale the page up to it 1:1 (identity) scale
		self.selectedPage.transform = CGAffineTransformIdentity; 
        
		// reveal the page header view
		headerView.alpha = 1.0f;
        
        // hide close button
        self.selectedPage.closeButton.alpha = 0.0f;
        
		//remove unnecessary views
        NSInteger pagesCount = [self.dataSource numberOfPagesInScrollView:self];
        for (NSInteger currentIndex = 0; currentIndex < pagesCount; pagesCount++) {
            TabPageView *currentPage = [self.dataSource pageScrollView:self viewForPageAtIndex:currentIndex];
            [currentPage removeFromSuperview];
        }

        //[self.closePageTouch removeFromSuperview];
	} : ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
		// move to TabPageScrollViewModeDeck
		//self.pageDeckTitleLabel.hidden = NO;
		[self initDeckTitlesForPageAtIndex:selectedIndex];
		
		self.selectedPage.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        
 		CGRect frame = self.selectedPage.frame;
        frame.origin.y = 0.0f;
        self.selectedPage.frame = frame;
        
        // display close button
        self.selectedPage.closeButton.alpha = 1.0f;
        
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
		//self.selectedPage.frame = CGRectMake(0.0f, headerView.frame.size.height, self.frame.size.width, self.selectedPage.frame.size.height);
		[self addSubview:self.selectedPage];
        
		// notify delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didSelectPageAtIndex:selectedIndex];
		}
	} : ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        /*
        if ([[self.selectedPage subviews] indexOfObject:self.selectedPage.closeButton] != NSNotFound) {
            [self addSubview:self.closePageTouch];
        }
        */
        
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

- (void)updateHeaderForPage:(TabPageView *)pageView withIndex:(NSInteger)index
{
    if ([self.selectedPage isEqual:pageView]) {
        [self updateHeaderForPageWithIndex:index];
    }
}

- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index
{
    page.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
    
    NSInteger xOffset = 0;
    NSInteger yOffset = 0;
    
    CGFloat margin = 30.0f;
	CGRect pageFrame = page.frame;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    for (NSInteger pageIndex = 0; pageIndex <= index; pageIndex++) {
        CGFloat pagesWidth = pageIndex * (pageFrame.size.width + margin);
        if (appFrame.size.width < pagesWidth) {
            xOffset = 1;
            yOffset++;
        }
    }
    
	pageFrame.origin.x = margin + (pageFrame.size.width  + margin) * xOffset;
	pageFrame.origin.y = margin + (pageFrame.size.height + margin) * yOffset;
    
	page.frame = pageFrame;
}

// add a page to the scroll view at a given index. No adjustments are made to existing pages offsets. 
- (void)addPageToDeck:(TabPageView *)page atIndex:(NSInteger)index
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
	[self.pageDeckBackgroundView addSubview:page];
}

- (void)reloadData
{
    NSInteger numPages = 1;  
	if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
		numPages = [self.dataSource numberOfPagesInScrollView:self];
	}
	
    NSInteger selectedIndex = self.selectedPage ? [self.visiblePages indexOfObject:self.selectedPage] : NSNotFound;
    
	// remove all subviews from scrollView
    /*
    [[self.pageDeckBackgroundView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    */
    
	self.numberOfPages = numPages;
	
    // hide view components initially
    self.pageHeaderView.alpha = 0.0f;	
    
	if (self.numberOfPages > 0) {
		// reload visible pages
		for (int index = 0; index < self.numberOfPages; index++) {
			TabPageView *page = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
            [self addPageToDeck:page atIndex:index];
		}
		
		// this will load any additional views which become visible  
		//[self updateVisiblePages];
		
        // set initial alpha values for all visible pages
        [self.visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //[self setAlphaForPage:obj];
        }];
		
        if (selectedIndex == NSNotFound) {
            // if no page is selected, select the first page
            self.selectedPage = [self.visiblePages objectAtIndex:0];
        } else {
            // refresh the page at the selected index (it might have changed after reloading the visible pages) 
            self.selectedPage = [self.visiblePages objectAtIndex:selectedIndex];
        }
        
        // IMPORTANT
        //self.closePageTouch.receiver = self.selectedPage.closeButton;
        
        // update deck title and subtitle for selected page
        NSInteger index = [self indexForSelectedPage];
        [self updateHeaderForPageWithIndex:index];
        
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
