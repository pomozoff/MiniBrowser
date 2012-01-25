//
//  TabPageScrollView.m
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabPageScrollView.h"

@implementation TabPageScrollView

@synthesize pageDeckBackgroundView = _pageDeckBackgroundView;
@synthesize pageHeaderView = _pageHeaderView;

@synthesize selectedPage = _selectedPage;
@synthesize deletedPages = _deletedPages;
@synthesize visiblePages = _visiblePages; // array of created tabs
@synthesize reusablePages = _reusablePages;

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

@synthesize viewMode = _viewMode;

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.viewMode = TabPageScrollViewModeDeck;
}

- (void)dealloc
{
    self.visiblePages = nil;
    self.deletedPages = nil;
    self.reusablePages = nil;

    self.delegate = nil;
    self.dataSource = nil;
    
    [super dealloc];
}

- (NSInteger)numberOfPages
{
    return 0;
}

- (TabPageView *)pageAtIndex:(NSInteger)index
{
    return nil;
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

- (void)setOriginForPage:(UIView *)page atIndex:(NSInteger)index
{
    
}

- (NSInteger)indexForSelectedPage
{
    return 0;
}

- (NSInteger)indexForVisiblePage:(TabPageView *)page
{
    return 0;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    
}

- (void)selectPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    
}

- (void)deselectPageAnimated:(BOOL)animated
{
    
}

- (void)reloadData
{
    
}

- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    
}

- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    
}

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes
{
    
}

- (void)updateHeaderForPage:(TabPageView *)pageView WithIndex:(NSInteger)index;
{
    
}

@end
