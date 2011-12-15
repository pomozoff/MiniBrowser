//
//  TabPageView.h
//  MiniBrowser
//
//  Created by Антон Помозов on 06.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabPageView : UIView <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, assign) CGRect identityFrame;
@property (nonatomic, copy) NSString *reuseIdentifier;

- (void)prepareForReuse;    // if the page is reusable (has a reuse identifier), this is called just before the cell is returned from HGPageScrollView method dequeueReusablePageWithIdentifier:.  If you override, you MUST call super.

@end
