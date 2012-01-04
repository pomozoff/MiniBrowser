//
//  PadTabPageScrollView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 05.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "TabPageScrollView.h"

@interface PadTabPageScrollView : TabPageScrollView

@property (nonatomic, retain) IBOutlet UIView *pageDeckBackgroundView;
@property (nonatomic, retain) IBOutlet UIView *pageHeaderView;

@property (nonatomic, retain) IBOutlet UILabel *pageDeckTitleLabel;
@property (nonatomic, retain) IBOutlet TabTouchView *closePageTouch;

@end
