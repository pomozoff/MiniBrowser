//
//  PadTabPageScrollView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "PadTabPageScrollView.h"

@interface PadTabPageScrollView()

- (void)reloadData; 
- (TabPageView *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex;
- (void)setViewMode:(TabPageScrollViewMode)mode animated:(BOOL)animated;

@end

@implementation PadTabPageScrollView

@synthesize pageDeckBackgroundView = _pageDeckBackgroundView;
@synthesize pageHeaderView = _pageHeaderView;

@synthesize pageDeckTitleLabel = _pageDeckTitleLabel;
@synthesize closePageTouch = _closePageTouch;

@synthesize selectedPage = _selectedPage;

// *******************************************************************************************************************************

#pragma mark Page Selection


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
        //self.selectedPage = [self.visiblePages objectAtIndex:selectedVisibleIndex];
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
    NSInteger selectedPageScrollIndex = [self indexForSelectedPage];
    CGRect identityFrame = self.selectedPage.identityFrame;
    CGRect pageFrame = self.selectedPage.frame;
    [self.selectedPage removeFromSuperview];
    self.selectedPage = [self loadPageAtIndex:selectedPageScrollIndex insertIntoVisibleIndex:visibleIndex];
    self.selectedPage.identityFrame = identityFrame;
    self.selectedPage.frame = pageFrame;
    self.selectedPage.alpha = 1.0;
    [self addSubview:self.selectedPage];
    
    self.closePageTouch.receiver = self.selectedPage.closeButton;
    
	[self setViewMode:TabPageScrollViewModeDeck animated:animated];
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
        
		[self.scrollView bringSubviewToFront:self.selectedPage];
		if ([self.dataSource respondsToSelector:@selector(pageScrollView:headerViewForPageAtIndex:)]) {
            UIView *altHeaderView = [self.dataSource pageScrollView:self headerViewForPageAtIndex:selectedIndex];
            
            [self.userHeaderView removeFromSuperview];
            self.userHeaderView = nil;
            
            if (altHeaderView) {
                //use the header view initialized by the dataSource 
                self.pageHeaderView.hidden = YES; 
                self.userHeaderView = altHeaderView;
                CGRect frame = self.userHeaderView.frame;
                frame.origin.y = 0.0f;
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
		frame.size.height -= headerView.frame.size.height;
		self.selectedPage.frame = frame;
		
		// reveal the page header view
		headerView.alpha = 1.0f;
        
        // hide close button
        self.selectedPage.closeButton.alpha = 0.0f;
        
		//remove unnecessary views
		[self.scrollViewTouch removeFromSuperview];
		[self.pageControlTouch removeFromSuperview];
        [self.closePageTouch removeFromSuperview];
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
        
		self.selectedPage.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        
 		CGRect frame = self.selectedPage.frame;
        frame.origin.y = 0.0f;
        self.selectedPage.frame = frame;
        
        // hide the page header view
        headerView.alpha = 0.0f;	
        
        // display close button
        self.selectedPage.closeButton.alpha = 1.0f;
        
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
		self.selectedPage.alpha = 1.0f;
        
		// copy self.selectedPage up in the view hierarchy, to allow touch events on its entire frame 
		self.selectedPage.frame = CGRectMake(0.0f, headerView.frame.size.height, self.frame.size.width, self.selectedPage.frame.size.height);
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
		[self addSubview:self.pageControlTouch];
        
        if ([[self.selectedPage subviews] indexOfObject:self.selectedPage.closeButton] != NSNotFound) {
            [self addSubview:self.closePageTouch];
        }
        
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
    if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
        self.pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
    }
    if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
        self.pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
    }	
}

- (void)updateHeaderForPage:(TabPageView *)pageView WithIndex:(NSInteger)index
{
    if ([self.selectedPage isEqual:pageView]) {
        [self updateHeaderForPageWithIndex:index];
    }
}

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
        
        self.closePageTouch.receiver = self.selectedPage.closeButton;
        
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
         */
        
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

@end
