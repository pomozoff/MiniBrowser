//
//  PhoneTabPageScrollView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 07.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "TabPageScrollView.h"

#define VISIBLE_PAGES_COUNT 3
#define REUSABLE_PAGES_COUNT 3

@interface PhoneTabPageScrollView : TabPageScrollView

@property (nonatomic, retain) UIView *userHeaderView;

@property (nonatomic, retain) IBOutlet UIView *pageDeckBackgroundView;
@property (nonatomic, retain) IBOutlet UIView *pageHeaderView;

@property (nonatomic, retain) IBOutlet UILabel *pageDeckTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *pageDeckSubtitleLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet TabTouchView *scrollViewTouch;

@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet TabTouchView  *pageControlTouch;

@property (nonatomic, retain) IBOutlet TabTouchView  *pageCloseTouch;

@end
