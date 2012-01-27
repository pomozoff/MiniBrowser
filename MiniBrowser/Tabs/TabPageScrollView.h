//
//  TabPageScrollView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabTouchView.h"
#import "TabPageView.h"

#define TRANSFORM_PAGE_SCALE_IPAD 0.25f
#define TRANSFORM_PAGE_SCALE_IPHONE 0.60f
#define ANIMATION_CHANGE_MODE_DURATION 0.3f

// *******************************************************************************************************************************

#pragma mark - Page Mode


typedef enum {
	TabPageScrollViewModePage,
	TabPageScrollViewModeDeck 
} TabPageScrollViewMode; 

// *******************************************************************************************************************************

#pragma mark - Page State Constants


typedef enum {
    TabPageScrollViewUpdateMethodInsert, 
    TabPageScrollViewUpdateMethodDelete, 
    TabPageScrollViewUpdateMethodReload
} TabPageScrollViewUpdateMethod;

// *******************************************************************************************************************************

#pragma mark - HGPageScrollView exception constants


#define kExceptionNameInvalidOperation   @"HGPageScrollView Invalid Operation"
#define kExceptionReasonInvalidOperation @"Updating HGPageScrollView data is only allowed in DECK mode, i.e. when the page scroller is visible."

#define kExceptionNameInvalidUpdate   @"HGPageScrollView DeletePagesAtIndexes Invalid Update"
#define kExceptionReasonInvalidUpdate @"The number of pages contained HGPageScrollView after the update (%d) must be equal to the number of pages contained in it before the update (%d), plus or minus the number of pages added or removed from it (%d added, %d removed)."

// *******************************************************************************************************************************

#pragma mark - Main


@class TabPageScrollView;

@protocol TabPageScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// Dragging
- (void)pageScrollViewWillBeginDragging:(TabPageScrollView *)scrollView;
- (void)pageScrollViewDidEndDragging:(TabPageScrollView *)scrollView willDecelerate:(BOOL)decelerate;

// Decelaration
- (void)pageScrollViewWillBeginDecelerating:(TabPageScrollView *)scrollView;
- (void)pageScrollViewDidEndDecelerating:(TabPageScrollView *)scrollView;

// Called before the page scrolls into the center of the view.
- (void)pageScrollView:(TabPageScrollView *)scrollView willScrollToPage:(TabPageView *)page atIndex:(NSInteger)index;

// Called after the page scrolls into the center of the view.
- (void)pageScrollView:(TabPageScrollView *)scrollView didScrollToPage:(TabPageView *)page atIndex:(NSInteger)index;

// Called before the user changes the selection.
- (void)pageScrollView:(TabPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(TabPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;

// Called after the user changes the selection.
- (void)pageScrollView:(TabPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(TabPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index;

// Close current page
- (void)closeCurrentPage;
- (void)closePageAtIndex:(NSInteger)index;

@end

@protocol TabPageScrollViewDataSource <NSObject>

@required

// Page display. Implementers should *always* try to reuse pageViews by setting each page's reuseIdentifier. 
// This mechanism works the same as in UITableViewCells.  
- (TabPageView *)pageScrollView:(TabPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;

- (NSUInteger)maxPagesAmount;

@optional

- (NSInteger)numberOfPagesInScrollView:(TabPageScrollView *)scrollView; // Default is 1 if not implemented

// you should re-use the UIView that you return here, only initialize it with appropriate values. 
- (UIView *)pageScrollView:(TabPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index;  

- (NSString *)pageScrollView:(TabPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
- (NSString *)pageScrollView:(TabPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  

@end

@interface TabPageScrollView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet UIView *pageDeckBackgroundView;
@property (nonatomic, retain) IBOutlet UIView *pageHeaderView;

@property (nonatomic, retain) TabPageView *selectedPage;
@property (nonatomic, retain) NSMutableArray *deletedPages;
@property (nonatomic, retain) NSMutableArray *visiblePages;
@property (nonatomic, retain) NSMutableDictionary *reusablePages;

@property (nonatomic, retain) IBOutlet id<TabPageScrollViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet id<TabPageScrollViewDataSource> dataSource;

@property (nonatomic, assign) TabPageScrollViewMode viewMode;

// ******************************************************************************************************************************
//
// Info 
//
- (NSInteger)numberOfPages;
- (TabPageView *)pageAtIndex:(NSInteger)index;

// -----------------------------------------------------------------------------------------------------------------------------------
//
// Appearance
//
- (TabPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier; // Used by the delegate to acquire an already allocated page, instead of allocating a new one
- (void)setOriginForPage:(UIView *)page atIndex:(NSInteger)index;
- (void)drawShadowForPage:(TabPageView *)page;

// -----------------------------------------------------------------------------------------------------------------------------------
//
// Selection
//
- (NSInteger)indexForSelectedPage;                    // returns the index of the currently selected page.
- (NSInteger)indexForVisiblePage:(TabPageView *)page; // returns the index of a page in the visible range

// Selects and deselects rows. These methods will not call the delegate methods (-pageScrollView:willSelectPageAtIndex: or pageScrollView:didSelectPageAtIndex:)
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)deselectPageAnimated:(BOOL)animated;

// -----------------------------------------------------------------------------------------------------------------------------------
//
// Data
//
- (void)reloadData;

// Page insertion/deletion/reloading.

// insert on or more pages into the page scroller. 
// This method invokes HGPageScrollViewDataSource method numberOfPagesInScrollView:. Specifically, it expects the new number of pages to be equal to the previous number of pages plus the number of inserted pages. If this is not the case an exception is thrown. 
// Insertions are animated only if animated is set to YES and the insertion is into the visible page range.  
- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;

// delete one or more pages from the page scroller. 
// This method invokes HGPageScrollViewDataSource method numberOfPagesInScrollView:. Specifically, it expects the new number of pages to be equal to the previous number of pages minus the number of deleted pages. If this is not the case an exception is thrown.  
// Deletions are animated only if animated is set to YES and the deletion is from the visible page range.  
- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes;

// Update page title and subtitle when deck mode
- (void)updateHeaderForPage:(TabPageView *)pageView WithIndex:(NSInteger)index;

@end
