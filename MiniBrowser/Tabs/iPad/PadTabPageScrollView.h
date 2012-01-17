//
//  PadTabPageScrollView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "TabPageScrollView.h"

#define MAX_TABS_COUNT 5
#define TRANSFORM_PAGE_SCALE 0.25f

@interface PadTabPageScrollView : TabPageScrollView

@property (nonatomic, retain) IBOutlet UIView *pageDeckBackgroundView;
@property (nonatomic, retain) IBOutlet UIView *pageHeaderView;

@end
