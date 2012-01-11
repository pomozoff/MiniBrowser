//
//  PadTabPageTemplate.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.01.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabTouchView.h"
#import "../PageTemplateDelegate.h"

@interface PadTabPageTemplate : UIViewController <PageTemplateDelegate>

@property (nonatomic, retain) IBOutlet UILabel *pageDeckTitleLabel;
@property (nonatomic, retain) IBOutlet TabTouchView *closePageTouch;

@end
