//
//  BrowserController.h
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserControllerProtocol.h"
#import "TabPageScrollView.h"

@interface BrowserController : UIViewController <UIWebViewDelegate,
                                                 UISearchBarDelegate,
                                                 UIActionSheetDelegate,
                                                 UIActionSheetDelegate,
                                                 UIPopoverControllerDelegate,
                                                 UITextFieldDelegate,
                                                 UINavigationControllerDelegate,
                                                 BrowserControllerDelegate,
                                                 TabPageScrollViewDelegate,
                                                 TabPageScrollViewDataSource>

@property (nonatomic, copy) NSString *xibNameScrollView;
@property (nonatomic, copy) NSString *xibNamePageView;
@property (nonatomic, assign) NSUInteger maxTabsAmount;

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIToolbar *tabsToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addTabButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneTabButton;
@property (nonatomic, retain) IBOutlet UIToolbar *navigationToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *tabsButton;
@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UILabel *urlLabel;

@property (nonatomic, retain) UIWebView *webView;

- (void)dismissOpenPopoversAndActionSheet;

@end
