//
//  BrowserController.h
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserControllerProtocol.h"

@interface BrowserController : UIViewController <UIWebViewDelegate,
                                                 UISearchBarDelegate,
                                                 UIActionSheetDelegate,
                                                 UIActionSheetDelegate,
                                                 UIPopoverControllerDelegate,
                                                 UINavigationControllerDelegate,
                                                 BrowserControllerDelegate>

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIToolbar *navigationToolbar;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UILabel *urlLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)dismissOpenPopoversAndActionSheet;

@end
