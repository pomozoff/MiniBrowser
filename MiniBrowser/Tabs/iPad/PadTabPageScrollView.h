//
//  PadTabPageScrollView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "TabPageScrollView.h"

#define VISIBLE_PAGES_COUNT 5

@interface PadTabPageScrollView : TabPageScrollView

@property (nonatomic, retain) IBOutlet UIView *pageDeckBackgroundView;
@property (nonatomic, retain) IBOutlet UIView *pageHeaderView;

@end
